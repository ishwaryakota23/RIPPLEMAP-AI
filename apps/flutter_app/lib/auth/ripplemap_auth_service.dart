import 'package:flutter/foundation.dart';
import 'package:ripplemap_client/ripplemap_client.dart';

class RippleMapAuthService {
  RippleMapAuthService({String? serverpodUrl})
    : _client = Client(
        serverpodUrl ??
            const String.fromEnvironment(
              'RIPPLEMAP_SERVERPOD_URL',
              defaultValue: 'http://localhost:8080/',
            ),
      ) {
    if (kIsWeb) {
      _client.cookieAuth = true;
    } else {
      _client.authKeyProvider = _MemoryAuthKeyProvider();
    }
  }

  final Client _client;

  Future<String?> currentUserId() => _client.auth.currentUserId();

  Future<void> login(String email, String password) async {
    final result = await _client.auth.login(email: email, password: password);
    _rememberToken(result.token);
  }

  Future<UuidValue> startRegistration(String email) =>
      _client.auth.startRegistration(email: email);

  Future<String> verifyRegistrationCode(
    UuidValue accountRequestId,
    String verificationCode,
  ) => _client.auth.verifyRegistrationCode(
    accountRequestId: accountRequestId,
    verificationCode: verificationCode,
  );

  Future<void> finishRegistration(
    String registrationToken,
    String password,
  ) async {
    final result = await _client.auth.finishRegistration(
      registrationToken: registrationToken,
      password: password,
    );
    _rememberToken(result.token);
  }

  Future<UuidValue> startPasswordReset(String email) =>
      _client.auth.startPasswordReset(email: email);

  Future<String> verifyPasswordResetCode(
    UuidValue passwordResetRequestId,
    String verificationCode,
  ) => _client.auth.verifyPasswordResetCode(
    passwordResetRequestId: passwordResetRequestId,
    verificationCode: verificationCode,
  );

  Future<void> finishPasswordReset(
    String finishPasswordResetToken,
    String newPassword,
  ) => _client.auth.finishPasswordReset(
    finishPasswordResetToken: finishPasswordResetToken,
    newPassword: newPassword,
  );

  Future<void> logout() async {
    await _client.auth.logout();
    if (_client.authKeyProvider case final _MemoryAuthKeyProvider provider) {
      provider.clear();
    }
  }

  void close() => _client.close();

  void _rememberToken(String token) {
    if (_client.authKeyProvider case final _MemoryAuthKeyProvider provider) {
      provider.setToken(token);
    }
  }
}

class _MemoryAuthKeyProvider implements ClientAuthKeyProvider {
  String? _token;

  void setToken(String token) => _token = token;

  void clear() => _token = null;

  @override
  Future<String?> get authHeaderValue async =>
      _token == null ? null : 'Bearer $_token';
}
