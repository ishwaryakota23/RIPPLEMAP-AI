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

abstract class AnalysisTask
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AnalysisTask._({
    required this.jobKey,
    required this.authUserId,
    required this.owner,
    required this.repository,
    required this.pullRequestNumber,
  });

  factory AnalysisTask({
    required String jobKey,
    required String authUserId,
    required String owner,
    required String repository,
    required int pullRequestNumber,
  }) = _AnalysisTaskImpl;

  factory AnalysisTask.fromJson(Map<String, dynamic> jsonSerialization) {
    return AnalysisTask(
      jobKey: jsonSerialization['jobKey'] as String,
      authUserId: jsonSerialization['authUserId'] as String,
      owner: jsonSerialization['owner'] as String,
      repository: jsonSerialization['repository'] as String,
      pullRequestNumber: jsonSerialization['pullRequestNumber'] as int,
    );
  }

  String jobKey;

  String authUserId;

  String owner;

  String repository;

  int pullRequestNumber;

  /// Returns a shallow copy of this [AnalysisTask]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AnalysisTask copyWith({
    String? jobKey,
    String? authUserId,
    String? owner,
    String? repository,
    int? pullRequestNumber,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AnalysisTask',
      'jobKey': jobKey,
      'authUserId': authUserId,
      'owner': owner,
      'repository': repository,
      'pullRequestNumber': pullRequestNumber,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AnalysisTask',
      'jobKey': jobKey,
      'authUserId': authUserId,
      'owner': owner,
      'repository': repository,
      'pullRequestNumber': pullRequestNumber,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AnalysisTaskImpl extends AnalysisTask {
  _AnalysisTaskImpl({
    required String jobKey,
    required String authUserId,
    required String owner,
    required String repository,
    required int pullRequestNumber,
  }) : super._(
         jobKey: jobKey,
         authUserId: authUserId,
         owner: owner,
         repository: repository,
         pullRequestNumber: pullRequestNumber,
       );

  /// Returns a shallow copy of this [AnalysisTask]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AnalysisTask copyWith({
    String? jobKey,
    String? authUserId,
    String? owner,
    String? repository,
    int? pullRequestNumber,
  }) {
    return AnalysisTask(
      jobKey: jobKey ?? this.jobKey,
      authUserId: authUserId ?? this.authUserId,
      owner: owner ?? this.owner,
      repository: repository ?? this.repository,
      pullRequestNumber: pullRequestNumber ?? this.pullRequestNumber,
    );
  }
}
