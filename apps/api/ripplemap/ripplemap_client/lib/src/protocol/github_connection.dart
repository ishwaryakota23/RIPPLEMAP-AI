/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class GitHubConnection
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  GitHubConnection._({
    this.id,
    this.sessionId,
    this.authUserId,
    required this.githubLogin,
    required this.encryptedAccessToken,
    required this.createdAt,
  });

  factory GitHubConnection({
    int? id,
    String? sessionId,
    String? authUserId,
    required String githubLogin,
    required String encryptedAccessToken,
    required DateTime createdAt,
  }) = _GitHubConnectionImpl;

  factory GitHubConnection.fromJson(Map<String, dynamic> jsonSerialization) {
    return GitHubConnection(
      id: jsonSerialization['id'] as int?,
      sessionId: jsonSerialization['sessionId'] as String?,
      authUserId: jsonSerialization['authUserId'] as String?,
      githubLogin: jsonSerialization['githubLogin'] as String,
      encryptedAccessToken: jsonSerialization['encryptedAccessToken'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String? sessionId;

  String? authUserId;

  String githubLogin;

  String encryptedAccessToken;

  DateTime createdAt;

  /// Returns a shallow copy of this [GitHubConnection]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  GitHubConnection copyWith({
    int? id,
    String? sessionId,
    String? authUserId,
    String? githubLogin,
    String? encryptedAccessToken,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GitHubConnection',
      if (id != null) 'id': id,
      if (sessionId != null) 'sessionId': sessionId,
      if (authUserId != null) 'authUserId': authUserId,
      'githubLogin': githubLogin,
      'encryptedAccessToken': encryptedAccessToken,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GitHubConnection',
      if (id != null) 'id': id,
      if (sessionId != null) 'sessionId': sessionId,
      if (authUserId != null) 'authUserId': authUserId,
      'githubLogin': githubLogin,
      'encryptedAccessToken': encryptedAccessToken,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GitHubConnectionImpl extends GitHubConnection {
  _GitHubConnectionImpl({
    int? id,
    String? sessionId,
    String? authUserId,
    required String githubLogin,
    required String encryptedAccessToken,
    required DateTime createdAt,
  }) : super._(
         id: id,
         sessionId: sessionId,
         authUserId: authUserId,
         githubLogin: githubLogin,
         encryptedAccessToken: encryptedAccessToken,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [GitHubConnection]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  GitHubConnection copyWith({
    Object? id = _Undefined,
    Object? sessionId = _Undefined,
    Object? authUserId = _Undefined,
    String? githubLogin,
    String? encryptedAccessToken,
    DateTime? createdAt,
  }) {
    return GitHubConnection(
      id: id is int? ? id : this.id,
      sessionId: sessionId is String? ? sessionId : this.sessionId,
      authUserId: authUserId is String? ? authUserId : this.authUserId,
      githubLogin: githubLogin ?? this.githubLogin,
      encryptedAccessToken: encryptedAccessToken ?? this.encryptedAccessToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
