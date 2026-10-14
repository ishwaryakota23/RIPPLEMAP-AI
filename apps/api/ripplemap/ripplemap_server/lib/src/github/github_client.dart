import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;

class GitHubClient {
  GitHubClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> exchangeCode(String code) async {
    final clientId = _requiredEnvironment('GITHUB_CLIENT_ID');
    final clientSecret = _requiredEnvironment('GITHUB_CLIENT_SECRET');
    final redirectUri = _requiredEnvironment(
      'GITHUB_REDIRECT_URI',
      fallback: 'http://localhost:8082/auth/github/callback',
    );
    final response = await _client
        .post(
          Uri.https('github.com', '/login/oauth/access_token'),
          headers: const {
            'Accept': 'application/json',
            'User-Agent': 'RippleMap-AI',
          },
          body: {
            'client_id': clientId,
            'client_secret': clientSecret,
            'code': code,
            'redirect_uri': redirectUri,
          },
        )
        .timeout(const Duration(seconds: 20));
    final body = _decodeObject(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GitHubApiException(
        response.statusCode,
        _message(body, 'GitHub authorization failed.'),
      );
    }
    final token = body['access_token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException(
        'GitHub did not return an access token. Check the OAuth app settings.',
      );
    }
    return body;
  }

  Future<Map<String, dynamic>> getObject(
    Uri uri, {
    required String token,
    String accept = 'application/vnd.github+json',
  }) async {
    final response = await _client
        .get(uri, headers: _headers(token, accept))
        .timeout(const Duration(seconds: 30));
    final body = _decodeObject(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GitHubApiException(
        response.statusCode,
        _message(body, 'GitHub API request failed.'),
      );
    }
    return body;
  }

  Future<List<Map<String, dynamic>>> getList(
    Uri uri, {
    required String token,
  }) async {
    final response = await _client
        .get(uri, headers: _headers(token, 'application/vnd.github+json'))
        .timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = _decodeObject(response.body);
      throw GitHubApiException(
        response.statusCode,
        _message(body, 'GitHub API request failed.'),
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException(
        'GitHub returned an unexpected list response.',
      );
    }
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Future<String> getRaw(
    Uri uri, {
    required String token,
    required int maximumBytes,
  }) async {
    final response = await _client
        .get(
          uri,
          headers: _headers(token, 'application/vnd.github.raw+json'),
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = _decodeObject(response.body);
      throw GitHubApiException(
        response.statusCode,
        _message(body, 'GitHub source retrieval failed.'),
      );
    }
    if (response.bodyBytes.length > maximumBytes) {
      throw const GitHubApiException(
        413,
        'The source file exceeded the analysis size limit.',
      );
    }
    return utf8.decode(response.bodyBytes, allowMalformed: false);
  }

  Future<Map<String, dynamic>> getCurrentUser(String token) => getObject(
    Uri.https('api.github.com', '/user'),
    token: token,
  );

  Future<List<Map<String, dynamic>>> listRepositories(String token) => getList(
    Uri.https('api.github.com', '/user/repos', {
      'sort': 'updated',
      'per_page': '100',
      'page': '1',
      'type': 'all',
    }),
    token: token,
  );

  Future<List<Map<String, dynamic>>> listPullRequests(
    String owner,
    String repository,
    String token,
  ) => getList(
    Uri.https(
      'api.github.com',
      '/repos/${Uri.encodeComponent(owner)}/${Uri.encodeComponent(repository)}/pulls',
      {
        'state': 'open',
        'sort': 'updated',
        'direction': 'desc',
        'per_page': '100',
      },
    ),
    token: token,
  );

  Future<List<Map<String, dynamic>>> listPullRequestFiles(
    String owner,
    String repository,
    int number,
    String token,
  ) => getList(
    Uri.https(
      'api.github.com',
      '/repos/${Uri.encodeComponent(owner)}/${Uri.encodeComponent(repository)}/pulls/$number/files',
      {'per_page': '100', 'page': '1'},
    ),
    token: token,
  );

  void close() => _client.close();

  Map<String, String> _headers(String token, String accept) => {
    'Accept': accept,
    'Authorization': 'Bearer $token',
    'X-GitHub-Api-Version': '2022-11-28',
    'User-Agent': 'RippleMap-AI',
  };

  static Map<String, dynamic> _decodeObject(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map) {
      throw const FormatException('GitHub returned an unexpected response.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  static String _message(Map<String, dynamic> body, String fallback) {
    final message = body['message'];
    if (message is! String || message.isEmpty) return fallback;
    return message.length > 240 ? '${message.substring(0, 240)}…' : message;
  }
}

class CredentialVault {
  CredentialVault()
    : _algorithm = AesGcm.with256bits(),
      _random = Random.secure();

  final AesGcm _algorithm;
  final Random _random;

  Future<String> encrypt(String token) async {
    final nonce = List<int>.generate(12, (_) => _random.nextInt(256));
    final box = await _algorithm.encrypt(
      utf8.encode(token),
      secretKey: SecretKey(_encryptionKey()),
      nonce: nonce,
    );
    return base64Encode([...box.nonce, ...box.cipherText, ...box.mac.bytes]);
  }

  Future<String> decrypt(String value) async {
    final bytes = base64Decode(value);
    if (bytes.length < 28) {
      throw const FormatException('The stored GitHub credential is invalid.');
    }
    final nonce = bytes.sublist(0, 12);
    final ciphertext = bytes.sublist(12, bytes.length - 16);
    final mac = bytes.sublist(bytes.length - 16);
    final cleartext = await _algorithm.decrypt(
      SecretBox(ciphertext, nonce: nonce, mac: Mac(mac)),
      secretKey: SecretKey(_encryptionKey()),
    );
    return utf8.decode(cleartext);
  }

  List<int> _encryptionKey() {
    final encoded = PlatformEnvironment.value('SESSION_ENCRYPTION_KEY');
    if (encoded == null || encoded.isEmpty) {
      throw StateError(
        'SESSION_ENCRYPTION_KEY must be configured before storing GitHub credentials.',
      );
    }
    final key = base64Url.decode(base64Url.normalize(encoded));
    if (key.length != 32) {
      throw StateError(
        'SESSION_ENCRYPTION_KEY must be a base64-encoded 32-byte key.',
      );
    }
    return key;
  }
}

String _requiredEnvironment(String name, {String? fallback}) {
  final value = PlatformEnvironment.value(name) ?? fallback;
  if (value == null || value.isEmpty) {
    throw StateError('$name is not configured on the Serverpod backend.');
  }
  return value;
}

class PlatformEnvironment {
  static Map<String, String>? _dotenv;

  static String? value(String name) {
    final compiled = String.fromEnvironment(name);
    if (compiled.isNotEmpty) return compiled;
    return Platform.environment[name] ?? _dotenvValues()[name];
  }

  static Map<String, String> _dotenvValues() {
    return _dotenv ??= _readDotenv();
  }

  static Map<String, String> _readDotenv() {
    var directory = Directory.current;
    while (true) {
      final file = File('${directory.path}${Platform.pathSeparator}.env');
      if (file.existsSync()) {
        return {
          for (final line in file.readAsLinesSync())
            if (_parseDotenvLine(line) case final entry?)
              entry.key: entry.value,
        };
      }
      final parent = directory.parent;
      if (parent.path == directory.path) return const {};
      directory = parent;
    }
  }

  static MapEntry<String, String>? _parseDotenvLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) return null;
    final separator = trimmed.indexOf('=');
    if (separator <= 0) return null;
    final name = trimmed.substring(0, separator).trim();
    if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(name)) return null;
    var value = trimmed.substring(separator + 1).trim();
    if (value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")))) {
      value = value.substring(1, value.length - 1);
    } else {
      final comment = value.indexOf(' #');
      if (comment >= 0) value = value.substring(0, comment).trimRight();
    }
    return MapEntry(name, value);
  }
}

class GitHubApiException implements Exception {
  const GitHubApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'GitHub API ($statusCode): $message';
}
