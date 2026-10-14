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

abstract class AnalysisReview
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AnalysisReview._({
    this.id,
    required this.authUserId,
    required this.jobKey,
    required this.decision,
    this.note,
    required this.updatedAt,
  });

  factory AnalysisReview({
    int? id,
    required String authUserId,
    required String jobKey,
    required String decision,
    String? note,
    required DateTime updatedAt,
  }) = _AnalysisReviewImpl;

  factory AnalysisReview.fromJson(Map<String, dynamic> jsonSerialization) {
    return AnalysisReview(
      id: jsonSerialization['id'] as int?,
      authUserId: jsonSerialization['authUserId'] as String,
      jobKey: jsonSerialization['jobKey'] as String,
      decision: jsonSerialization['decision'] as String,
      note: jsonSerialization['note'] as String?,
      updatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String authUserId;

  String jobKey;

  String decision;

  String? note;

  DateTime updatedAt;

  /// Returns a shallow copy of this [AnalysisReview]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AnalysisReview copyWith({
    int? id,
    String? authUserId,
    String? jobKey,
    String? decision,
    String? note,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AnalysisReview',
      if (id != null) 'id': id,
      'authUserId': authUserId,
      'jobKey': jobKey,
      'decision': decision,
      if (note != null) 'note': note,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AnalysisReview',
      if (id != null) 'id': id,
      'authUserId': authUserId,
      'jobKey': jobKey,
      'decision': decision,
      if (note != null) 'note': note,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AnalysisReviewImpl extends AnalysisReview {
  _AnalysisReviewImpl({
    int? id,
    required String authUserId,
    required String jobKey,
    required String decision,
    String? note,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         jobKey: jobKey,
         decision: decision,
         note: note,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AnalysisReview]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AnalysisReview copyWith({
    Object? id = _Undefined,
    String? authUserId,
    String? jobKey,
    String? decision,
    Object? note = _Undefined,
    DateTime? updatedAt,
  }) {
    return AnalysisReview(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      jobKey: jobKey ?? this.jobKey,
      decision: decision ?? this.decision,
      note: note is String? ? note : this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
