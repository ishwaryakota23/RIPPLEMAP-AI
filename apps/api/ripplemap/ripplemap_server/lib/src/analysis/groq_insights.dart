import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ripplemap_server/src/github/github_client.dart';

class GroqInsights {
  GroqInsights({http.Client? client, this.apiKey, this.model})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String? apiKey;
  final String? model;

  Future<Map<String, Object?>> explain(
    Map<String, Object?> report,
  ) async {
    final apiKey = (this.apiKey ?? PlatformEnvironment.value('GROQ_API_KEY'))
        ?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      return _unavailable('GROQ_API_KEY is not configured on the backend.');
    }

    try {
      final model = await _selectModel(apiKey);
      if (model == null) {
        return _unavailable(
          'No supported chat model is available to this Groq account.',
        );
      }
      final response = await _client
          .post(
            Uri.https('api.groq.com', '/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'temperature': 0.2,
              'response_format': {'type': 'json_object'},
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You explain code-change risk using only supplied diff and parser evidence. Do not invent dependency edges or assert that code will fail. Put uncertain ideas in hypotheses. Return one JSON object with string summary, array insights of objects with string text, and array recommendations of objects with string text. Keep each list to at most five short items.',
                },
                {'role': 'user', 'content': _evidencePrompt(report)},
              ],
            }),
          )
          .timeout(const Duration(seconds: 25));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _unavailable(
          'Groq returned HTTP ${response.statusCode}; deterministic findings are unaffected.',
        );
      }
      final body = jsonDecode(response.body);
      if (body is! Map) {
        return _unavailable(
          'Groq returned an invalid response; deterministic findings are unaffected.',
        );
      }
      final choices = body['choices'];
      final first = choices is List && choices.isNotEmpty
          ? choices.first
          : null;
      final message = first is Map ? first['message'] : null;
      final content = message is Map ? message['content'] : null;
      if (content is! String) {
        return _unavailable(
          'Groq returned no structured content; deterministic findings are unaffected.',
        );
      }
      final parsed = jsonDecode(content);
      if (parsed is! Map ||
          parsed['summary'] is! String ||
          parsed['insights'] is! List ||
          parsed['recommendations'] is! List) {
        return _unavailable(
          'Groq returned an unexpected structured response; deterministic findings are unaffected.',
        );
      }
      final insights = _textItems(parsed['insights']);
      final recommendations = _textItems(parsed['recommendations']);
      final summary = _boundedText(parsed['summary'] as String);
      return {
        'aiStatus': 'available',
        'aiModel': model,
        'aiInsights': [
          {'text': 'AI hypothesis summary: $summary'},
          ...insights.map((text) => {'text': 'AI hypothesis: $text'}),
        ],
        'aiRecommendations': recommendations
            .map((text) => {'text': 'AI hypothesis to verify: $text'})
            .toList(growable: false),
      };
    } on Exception catch (error) {
      return _unavailable(
        'Groq insights are temporarily unavailable (${_safeReason(error)}); deterministic findings are unaffected.',
      );
    }
  }

  Future<String?> _selectModel(String apiKey) async {
    final configured = (model ?? PlatformEnvironment.value('GROQ_MODEL'))
        ?.trim();
    final response = await _client
        .get(
          Uri.https('api.groq.com', '/openai/v1/models'),
          headers: {'Authorization': 'Bearer $apiKey'},
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GroqUnavailableException(
        'Groq model discovery returned HTTP ${response.statusCode}.',
      );
    }
    final decoded = jsonDecode(response.body);
    final data = decoded is Map ? decoded['data'] : null;
    if (data is! List) {
      throw const FormatException('Groq returned an invalid model list.');
    }
    final available = data
        .whereType<Map>()
        .map((item) => item['id'])
        .whereType<String>()
        .toSet();
    if (configured != null && configured.isNotEmpty) {
      if (!available.contains(configured)) {
        throw GroqUnavailableException(
          'Configured GROQ_MODEL is not available to this account.',
        );
      }
      return configured;
    }
    final models = available.toList()..sort();
    for (final model in models) {
      if (model.contains('llama') ||
          model.contains('gpt-oss') ||
          model.contains('qwen') ||
          model.contains('deepseek')) {
        return model;
      }
    }
    return null;
  }

  String _evidencePrompt(Map<String, Object?> report) {
    final changedFiles = report['changedFiles'];
    final diff = changedFiles is List
        ? changedFiles
              .whereType<Map>()
              .take(8)
              .map((file) {
                final patch = file['patch'];
                final excerpt = patch is String && patch.length > 4000
                    ? '${patch.substring(0, 4000)}\n[patch excerpt truncated]'
                    : patch ?? '[patch unavailable]';
                return '${file['path']}: $excerpt';
              })
              .join('\n')
        : '';
    final evidence = {
      'diff': diff,
      'confirmedDirectImports': _boundedItems(report['directImpacts'], 8),
      'potentialTransitiveImpacts': _boundedItems(
        report['potentialImpacts'],
        8,
      ),
      'changedExports': _boundedItems(report['changedSymbols'], 8),
      'limitations': _boundedItems(report['limitations'], 6),
    };
    final encoded = jsonEncode(evidence);
    return encoded.length <= 18000
        ? encoded
        : '${encoded.substring(0, 18000)} [evidence truncated]';
  }

  List<Object?> _boundedItems(Object? value, int maximum) {
    if (value is! List) return const [];
    return value.take(maximum).toList(growable: false);
  }

  List<String> _textItems(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => item['text'])
        .whereType<String>()
        .map(_boundedText)
        .where((text) => text.isNotEmpty)
        .take(5)
        .toList(growable: false);
  }

  String _boundedText(String value) {
    final normalized = value.trim();
    return normalized.length > 500
        ? '${normalized.substring(0, 500)}…'
        : normalized;
  }

  String _safeReason(Exception error) {
    if (error is GroqUnavailableException) return error.message;
    if (error is FormatException) return 'malformed response';
    if (error is http.ClientException) return 'network request failed';
    if (error is TimeoutException) return 'request timed out';
    return 'request could not be completed';
  }

  Map<String, Object?> _unavailable(String reason) => {
    'aiStatus': 'unavailable',
    'aiInsights': <Map<String, String>>[],
    'aiRecommendations': <Map<String, String>>[],
    'aiUnavailableReason': reason,
  };

  void close() => _client.close();
}

class GroqUnavailableException implements Exception {
  const GroqUnavailableException(this.message);

  final String message;
}
