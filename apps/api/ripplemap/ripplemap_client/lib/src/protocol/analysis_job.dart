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

abstract class AnalysisJob
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AnalysisJob._({
    this.id,
    required this.jobKey,
    this.sessionId,
    this.authUserId,
    required this.owner,
    required this.repository,
    required this.pullRequestNumber,
    required this.status,
    this.reportJson,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnalysisJob({
    int? id,
    required String jobKey,
    String? sessionId,
    String? authUserId,
    required String owner,
    required String repository,
    required int pullRequestNumber,
    required String status,
    String? reportJson,
    String? errorMessage,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AnalysisJobImpl;

  factory AnalysisJob.fromJson(Map<String, dynamic> jsonSerialization) {
    return AnalysisJob(
      id: jsonSerialization['id'] as int?,
      jobKey: jsonSerialization['jobKey'] as String,
      sessionId: jsonSerialization['sessionId'] as String?,
      authUserId: jsonSerialization['authUserId'] as String?,
      owner: jsonSerialization['owner'] as String,
      repository: jsonSerialization['repository'] as String,
      pullRequestNumber: jsonSerialization['pullRequestNumber'] as int,
      status: jsonSerialization['status'] as String,
      reportJson: jsonSerialization['reportJson'] as String?,
      errorMessage: jsonSerialization['errorMessage'] as String?,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String jobKey;

  String? sessionId;

  String? authUserId;

  String owner;

  String repository;

  int pullRequestNumber;

  String status;

  String? reportJson;

  String? errorMessage;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [AnalysisJob]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AnalysisJob copyWith({
    int? id,
    String? jobKey,
    String? sessionId,
    String? authUserId,
    String? owner,
    String? repository,
    int? pullRequestNumber,
    String? status,
    String? reportJson,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AnalysisJob',
      if (id != null) 'id': id,
      'jobKey': jobKey,
      if (sessionId != null) 'sessionId': sessionId,
      if (authUserId != null) 'authUserId': authUserId,
      'owner': owner,
      'repository': repository,
      'pullRequestNumber': pullRequestNumber,
      'status': status,
      if (reportJson != null) 'reportJson': reportJson,
      if (errorMessage != null) 'errorMessage': errorMessage,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AnalysisJob',
      if (id != null) 'id': id,
      'jobKey': jobKey,
      if (sessionId != null) 'sessionId': sessionId,
      if (authUserId != null) 'authUserId': authUserId,
      'owner': owner,
      'repository': repository,
      'pullRequestNumber': pullRequestNumber,
      'status': status,
      if (reportJson != null) 'reportJson': reportJson,
      if (errorMessage != null) 'errorMessage': errorMessage,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AnalysisJobImpl extends AnalysisJob {
  _AnalysisJobImpl({
    int? id,
    required String jobKey,
    String? sessionId,
    String? authUserId,
    required String owner,
    required String repository,
    required int pullRequestNumber,
    required String status,
    String? reportJson,
    String? errorMessage,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         jobKey: jobKey,
         sessionId: sessionId,
         authUserId: authUserId,
         owner: owner,
         repository: repository,
         pullRequestNumber: pullRequestNumber,
         status: status,
         reportJson: reportJson,
         errorMessage: errorMessage,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AnalysisJob]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AnalysisJob copyWith({
    Object? id = _Undefined,
    String? jobKey,
    Object? sessionId = _Undefined,
    Object? authUserId = _Undefined,
    String? owner,
    String? repository,
    int? pullRequestNumber,
    String? status,
    Object? reportJson = _Undefined,
    Object? errorMessage = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnalysisJob(
      id: id is int? ? id : this.id,
      jobKey: jobKey ?? this.jobKey,
      sessionId: sessionId is String? ? sessionId : this.sessionId,
      authUserId: authUserId is String? ? authUserId : this.authUserId,
      owner: owner ?? this.owner,
      repository: repository ?? this.repository,
      pullRequestNumber: pullRequestNumber ?? this.pullRequestNumber,
      status: status ?? this.status,
      reportJson: reportJson is String? ? reportJson : this.reportJson,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
