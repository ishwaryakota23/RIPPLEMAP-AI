import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

class AuthEndpoint extends EmailIdpBaseEndpoint {
  @override
  bool get requireLogin => false;

  Future<String?> currentUserId(Session session) async =>
      session.authenticated?.userIdentifier;

  Future<void> logout(Session session) async {
    final authentication = session.authenticated;
    if (authentication == null) return;
    await AuthServices.instance.tokenManager.revokeToken(
      session,
      tokenId: authentication.authId,
      tokenIssuer: ServerSideSessionsTokenManager.tokenIssuerName,
    );
    session.clearWebAuthCookie();
  }
}
