import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'http_client_factory.dart';

class RippleMapApi {
  RippleMapApi({String? baseUrl, http.Client? client})
    : baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'RIPPLEMAP_API_URL',
            defaultValue: 'http://localhost:8082',
          ),
      _client = client ?? createHttpClient();

  final String baseUrl;
  final http.Client _client;

  Future<Map<String, dynamic>> getConfiguration() => _get('/api/configuration');

  Future<List<Map<String, dynamic>>> getRepositories() async =>
      _list(await _get('/api/repositories'));

  Future<Map<String, dynamic>> getUserSettings() => _get('/api/user-settings');

  Future<Map<String, dynamic>> saveSelectedRepository(String repository) =>
      _post('/api/user-settings', {'selectedRepository': repository});

  Future<void> disconnectGitHub() async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/github/connection'),
      headers: _headers(),
    );
    _decode(response);
  }

  Future<List<Map<String, dynamic>>> getAnalysisHistory() async =>
      _list(await _get('/api/analyses/history'));

  Future<Map<String, dynamic>> saveAnalysisReview(
    String analysisId, {
    required String decision,
    String? note,
  }) => _post('/api/analyses/${Uri.encodeComponent(analysisId)}/review', {
    'decision': decision,
    if (note != null) 'note': note,
  });

  Future<List<Map<String, dynamic>>> getPullRequests(
    String owner,
    String repository,
  ) async => _list(
    await _get(
      '/api/repositories/${Uri.encodeComponent(owner)}/'
      '${Uri.encodeComponent(repository)}/pull-requests',
    ),
  );

  Future<Map<String, dynamic>> startAnalysis(
    String owner,
    String repository,
    int pullRequestNumber,
  ) => _post('/api/analyses', {
    'owner': owner,
    'repository': repository,
    'pullRequestNumber': pullRequestNumber,
  });

  Future<Map<String, dynamic>> getAnalysis(String id) =>
      _get('/api/analyses/${Uri.encodeComponent(id)}');

  Uri get connectUri => Uri.parse('$baseUrl/auth/github/start');

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers(),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, Object> body,
  ) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (kIsWeb) 'X-Serverpod-Auth-Mode': 'cookie',
      },
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, String> _headers() => {
    'Accept': 'application/json',
    if (kIsWeb) 'X-Serverpod-Auth-Mode': 'cookie',
  };

  Map<String, dynamic> _decode(http.Response response) {
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RippleMapApiException(
        decoded['message'] as String? ??
            'Request failed with status ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }
    return decoded;
  }

  List<Map<String, dynamic>> _list(Map<String, dynamic> response) {
    final items = response['items'];
    if (items is! List) {
      throw const FormatException('The API response did not contain items.');
    }
    return items
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  void close() => _client.close();
}

class RippleMapApiException implements Exception {
  const RippleMapApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
