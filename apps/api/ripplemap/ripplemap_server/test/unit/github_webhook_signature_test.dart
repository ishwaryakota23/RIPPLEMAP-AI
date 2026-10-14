import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:ripplemap_server/src/web/github_webhook_signature.dart';
import 'package:test/test.dart';

void main() {
  const secret = 'webhook-test-secret';
  final body = utf8.encode('{"action":"opened"}');
  final signature = 'sha256=${Hmac(sha256, utf8.encode(secret)).convert(body)}';

  test('accepts a valid SHA-256 signature for the exact request body', () {
    expect(isValidGitHubWebhookSignature(body, signature, secret), isTrue);
  });

  test('rejects a signature for a different body', () {
    expect(
      isValidGitHubWebhookSignature(
        utf8.encode('{"action":"closed"}'),
        signature,
        secret,
      ),
      isFalse,
    );
  });

  test('rejects malformed signatures and other digest algorithms', () {
    final zeros = List.filled(40, '0').join();
    expect(isValidGitHubWebhookSignature(body, 'sha1=$zeros', secret), isFalse);
    expect(
      isValidGitHubWebhookSignature(body, 'sha256=not-hex', secret),
      isFalse,
    );
  });
}
