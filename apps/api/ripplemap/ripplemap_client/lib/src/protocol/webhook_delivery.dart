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

abstract class WebhookDelivery
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WebhookDelivery._({
    this.id,
    required this.deliveryId,
    required this.eventType,
    required this.receivedAt,
  });

  factory WebhookDelivery({
    int? id,
    required String deliveryId,
    required String eventType,
    required DateTime receivedAt,
  }) = _WebhookDeliveryImpl;

  factory WebhookDelivery.fromJson(Map<String, dynamic> jsonSerialization) {
    return WebhookDelivery(
      id: jsonSerialization['id'] as int?,
      deliveryId: jsonSerialization['deliveryId'] as String,
      eventType: jsonSerialization['eventType'] as String,
      receivedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String deliveryId;

  String eventType;

  DateTime receivedAt;

  /// Returns a shallow copy of this [WebhookDelivery]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WebhookDelivery copyWith({
    int? id,
    String? deliveryId,
    String? eventType,
    DateTime? receivedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WebhookDelivery',
      if (id != null) 'id': id,
      'deliveryId': deliveryId,
      'eventType': eventType,
      'receivedAt': receivedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WebhookDelivery',
      if (id != null) 'id': id,
      'deliveryId': deliveryId,
      'eventType': eventType,
      'receivedAt': receivedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WebhookDeliveryImpl extends WebhookDelivery {
  _WebhookDeliveryImpl({
    int? id,
    required String deliveryId,
    required String eventType,
    required DateTime receivedAt,
  }) : super._(
         id: id,
         deliveryId: deliveryId,
         eventType: eventType,
         receivedAt: receivedAt,
       );

  /// Returns a shallow copy of this [WebhookDelivery]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WebhookDelivery copyWith({
    Object? id = _Undefined,
    String? deliveryId,
    String? eventType,
    DateTime? receivedAt,
  }) {
    return WebhookDelivery(
      id: id is int? ? id : this.id,
      deliveryId: deliveryId ?? this.deliveryId,
      eventType: eventType ?? this.eventType,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}
