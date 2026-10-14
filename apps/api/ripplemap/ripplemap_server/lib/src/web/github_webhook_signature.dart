import 'dart:convert';

import 'package:crypto/crypto.dart';

bool isValidGitHubWebhookSignature(
  List<int> body,
  String signature,
  String secret,
) {
  if (!signature.startsWith('sha256=')) return false;
  final supplied = signature.substring(7);
  if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(supplied)) return false;
  final expected = Hmac(sha256, utf8.encode(secret)).convert(body).bytes;
  final provided = List<int>.generate(
    32,
    (index) => int.parse(
      supplied.substring(index * 2, index * 2 + 2),
      radix: 16,
    ),
  );
  var mismatch = 0;
  for (var index = 0; index < expected.length; index++) {
    mismatch |= expected[index] ^ provided[index];
  }

  return mismatch == 0;
}
