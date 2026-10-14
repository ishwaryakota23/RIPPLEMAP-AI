import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ripplemap_server/src/analysis/groq_insights.dart';
import 'package:test/test.dart';

void main() {
  const apiKey = 'test-groq-key';
  const model = 'openai/gpt-oss-20b';

  test('sends authenticated model and completion requests', () async {
    var authorizationValid = true;
    final client = MockClient((request) async {
      authorizationValid &=
          request.headers['authorization'] == 'Bearer $apiKey';
      if (request.url.path == '/openai/v1/models') {
        return http.Response(
          jsonEncode({
            'data': [
              {'id': model},
            ],
          }),
          200,
        );
      }
      expect(request.url.path, '/openai/v1/chat/completions');
      return http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {
                'content': jsonEncode({
                  'summary': 'One changed module has a direct consumer.',
                  'insights': [
                    {'text': 'The consumer imports the changed module.'},
                  ],
                  'recommendations': [
                    {'text': 'Run the consumer test.'},
                  ],
                }),
              },
            },
          ],
        }),
        200,
      );
    });
    final insights = GroqInsights(
      client: client,
      apiKey: apiKey,
      model: model,
    );
    addTearDown(insights.close);

    final response = await insights.explain({
      'changedFiles': <Object?>[],
      'directImpacts': <Object?>[],
    });

    expect(authorizationValid, isTrue);
    expect(response['aiStatus'], 'available');
    expect(response['aiModel'], model);
    expect(response['aiInsights'], isNotEmpty);
    expect(response['aiRecommendations'], isNotEmpty);
  });

  test('keeps AI optional when model discovery fails', () async {
    final client = MockClient(
      (_) async => http.Response('unavailable', 503),
    );
    final insights = GroqInsights(
      client: client,
      apiKey: apiKey,
      model: model,
    );
    addTearDown(insights.close);

    final response = await insights.explain({
      'deterministicFindings': [
        {'type': 'confirmed_dependency', 'file': 'src/consumer.ts'},
      ],
    });

    expect(response['aiStatus'], 'unavailable');
    expect(response['aiUnavailableReason'], contains('HTTP 503'));
    expect(response['deterministicFindings'], isNull);
  });
}
