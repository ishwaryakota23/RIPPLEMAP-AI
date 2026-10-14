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

abstract class UserSettings
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  UserSettings._({
    this.id,
    required this.authUserId,
    this.selectedRepository,
    required this.updatedAt,
  });

  factory UserSettings({
    int? id,
    required String authUserId,
    String? selectedRepository,
    required DateTime updatedAt,
  }) = _UserSettingsImpl;

  factory UserSettings.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserSettings(
      id: jsonSerialization['id'] as int?,
      authUserId: jsonSerialization['authUserId'] as String,
      selectedRepository: jsonSerialization['selectedRepository'] as String?,
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

  String? selectedRepository;

  DateTime updatedAt;

  /// Returns a shallow copy of this [UserSettings]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UserSettings copyWith({
    int? id,
    String? authUserId,
    String? selectedRepository,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserSettings',
      if (id != null) 'id': id,
      'authUserId': authUserId,
      if (selectedRepository != null) 'selectedRepository': selectedRepository,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserSettings',
      if (id != null) 'id': id,
      'authUserId': authUserId,
      if (selectedRepository != null) 'selectedRepository': selectedRepository,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserSettingsImpl extends UserSettings {
  _UserSettingsImpl({
    int? id,
    required String authUserId,
    String? selectedRepository,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         selectedRepository: selectedRepository,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [UserSettings]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UserSettings copyWith({
    Object? id = _Undefined,
    String? authUserId,
    Object? selectedRepository = _Undefined,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      selectedRepository: selectedRepository is String?
          ? selectedRepository
          : this.selectedRepository,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
