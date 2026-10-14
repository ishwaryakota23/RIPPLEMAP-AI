/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'analysis_job.dart' as _icoe589w;
import 'analysis_review.dart' as _ietl2qzc;
import 'analysis_task.dart' as _ieyb3px7;
import 'github_connection.dart' as _iznipjmo;
import 'user_settings.dart' as _iy88a0nt;
import 'webhook_delivery.dart' as _i3fnt4w0;
export 'analysis_job.dart';
export 'analysis_review.dart';
export 'analysis_task.dart';
export 'github_connection.dart';
export 'user_settings.dart';
export 'webhook_delivery.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _icoe589w.AnalysisJob) {
      return _icoe589w.AnalysisJob.fromJson(data) as T;
    }
    if (t == _ietl2qzc.AnalysisReview) {
      return _ietl2qzc.AnalysisReview.fromJson(data) as T;
    }
    if (t == _ieyb3px7.AnalysisTask) {
      return _ieyb3px7.AnalysisTask.fromJson(data) as T;
    }
    if (t == _iznipjmo.GitHubConnection) {
      return _iznipjmo.GitHubConnection.fromJson(data) as T;
    }
    if (t == _iy88a0nt.UserSettings) {
      return _iy88a0nt.UserSettings.fromJson(data) as T;
    }
    if (t == _i3fnt4w0.WebhookDelivery) {
      return _i3fnt4w0.WebhookDelivery.fromJson(data) as T;
    }
    if (t == _isc.getType<_icoe589w.AnalysisJob?>()) {
      return (data != null ? _icoe589w.AnalysisJob.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ietl2qzc.AnalysisReview?>()) {
      return (data != null ? _ietl2qzc.AnalysisReview.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ieyb3px7.AnalysisTask?>()) {
      return (data != null ? _ieyb3px7.AnalysisTask.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iznipjmo.GitHubConnection?>()) {
      return (data != null ? _iznipjmo.GitHubConnection.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iy88a0nt.UserSettings?>()) {
      return (data != null ? _iy88a0nt.UserSettings.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i3fnt4w0.WebhookDelivery?>()) {
      return (data != null ? _i3fnt4w0.WebhookDelivery.fromJson(data) : null)
          as T;
    }
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _icoe589w.AnalysisJob => 'AnalysisJob',
      _ietl2qzc.AnalysisReview => 'AnalysisReview',
      _ieyb3px7.AnalysisTask => 'AnalysisTask',
      _iznipjmo.GitHubConnection => 'GitHubConnection',
      _iy88a0nt.UserSettings => 'UserSettings',
      _i3fnt4w0.WebhookDelivery => 'WebhookDelivery',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('ripplemap.', '');
    }

    switch (data) {
      case _icoe589w.AnalysisJob():
        return 'AnalysisJob';
      case _ietl2qzc.AnalysisReview():
        return 'AnalysisReview';
      case _ieyb3px7.AnalysisTask():
        return 'AnalysisTask';
      case _iznipjmo.GitHubConnection():
        return 'GitHubConnection';
      case _iy88a0nt.UserSettings():
        return 'UserSettings';
      case _i3fnt4w0.WebhookDelivery():
        return 'WebhookDelivery';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AnalysisJob') {
      return deserialize<_icoe589w.AnalysisJob>(data['data']);
    }
    if (dataClassName == 'AnalysisReview') {
      return deserialize<_ietl2qzc.AnalysisReview>(data['data']);
    }
    if (dataClassName == 'AnalysisTask') {
      return deserialize<_ieyb3px7.AnalysisTask>(data['data']);
    }
    if (dataClassName == 'GitHubConnection') {
      return deserialize<_iznipjmo.GitHubConnection>(data['data']);
    }
    if (dataClassName == 'UserSettings') {
      return deserialize<_iy88a0nt.UserSettings>(data['data']);
    }
    if (dataClassName == 'WebhookDelivery') {
      return deserialize<_i3fnt4w0.WebhookDelivery>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iacc.Protocol().registerHostProtocol('ripplemap', this);
    _iaic.Protocol().registerHostProtocol('ripplemap', this);
  }

  @override
  String getModuleName() => 'ripplemap';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
