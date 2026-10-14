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
import 'package:serverpod/serverpod.dart' as _is;

abstract class WebhookDelivery
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
    );
  }

  static final t = WebhookDeliveryTable();

  static const db = WebhookDeliveryRepository._();

  @override
  int? id;

  String deliveryId;

  String eventType;

  DateTime receivedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [WebhookDelivery]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static WebhookDeliveryInclude include() {
    return WebhookDeliveryInclude._();
  }

  static WebhookDeliveryIncludeList includeList({
    _is.WhereExpressionBuilder<WebhookDeliveryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WebhookDeliveryTable>? orderBy,
    _is.OrderByListBuilder<WebhookDeliveryTable>? orderByList,
    WebhookDeliveryInclude? include,
  }) {
    return WebhookDeliveryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WebhookDelivery.t),
      orderByList: orderByList?.call(WebhookDelivery.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class WebhookDeliveryUpdateTable extends _is.UpdateTable<WebhookDeliveryTable> {
  WebhookDeliveryUpdateTable(super.table);

  _is.ColumnValue<String, String> deliveryId(String value) => _is.ColumnValue(
    table.deliveryId,
    value,
  );

  _is.ColumnValue<String, String> eventType(String value) => _is.ColumnValue(
    table.eventType,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> receivedAt(DateTime value) =>
      _is.ColumnValue(
        table.receivedAt,
        value,
      );
}

class WebhookDeliveryTable extends _is.Table<int?> {
  WebhookDeliveryTable({super.tableRelation})
    : super(tableName: 'webhook_delivery') {
    updateTable = WebhookDeliveryUpdateTable(this);
    deliveryId = _is.ColumnString(
      'deliveryId',
      this,
    );
    eventType = _is.ColumnString(
      'eventType',
      this,
    );
    receivedAt = _is.ColumnDateTime(
      'receivedAt',
      this,
    );
  }

  late final WebhookDeliveryUpdateTable updateTable;

  late final _is.ColumnString deliveryId;

  late final _is.ColumnString eventType;

  late final _is.ColumnDateTime receivedAt;

  @override
  List<_is.Column> get columns => [
    id,
    deliveryId,
    eventType,
    receivedAt,
  ];
}

class WebhookDeliveryInclude extends _is.IncludeObject {
  WebhookDeliveryInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => WebhookDelivery.t;
}

class WebhookDeliveryIncludeList extends _is.IncludeList {
  WebhookDeliveryIncludeList._({
    _is.WhereExpressionBuilder<WebhookDeliveryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WebhookDelivery.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => WebhookDelivery.t;
}

class WebhookDeliveryRepository {
  const WebhookDeliveryRepository._();

  /// Returns a list of [WebhookDelivery]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<WebhookDelivery>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WebhookDeliveryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WebhookDeliveryTable>? orderBy,
    _is.OrderByListBuilder<WebhookDeliveryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<WebhookDelivery>(
      where: where?.call(WebhookDelivery.t),
      orderBy: orderBy?.call(WebhookDelivery.t),
      orderByList: orderByList?.call(WebhookDelivery.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [WebhookDelivery] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<WebhookDelivery?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WebhookDeliveryTable>? where,
    int? offset,
    _is.OrderByBuilder<WebhookDeliveryTable>? orderBy,
    _is.OrderByListBuilder<WebhookDeliveryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<WebhookDelivery>(
      where: where?.call(WebhookDelivery.t),
      orderBy: orderBy?.call(WebhookDelivery.t),
      orderByList: orderByList?.call(WebhookDelivery.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [WebhookDelivery] by its [id] or null if no such row exists.
  Future<WebhookDelivery?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<WebhookDelivery>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [WebhookDelivery]s in the list and returns the inserted rows.
  ///
  /// The returned [WebhookDelivery]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WebhookDelivery>> insert(
    _is.DatabaseSession session,
    List<WebhookDelivery> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<WebhookDelivery>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [WebhookDelivery] and returns the inserted row.
  ///
  /// The returned [WebhookDelivery] will have its `id` field set.
  Future<WebhookDelivery> insertRow(
    _is.DatabaseSession session,
    WebhookDelivery row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<WebhookDelivery>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [WebhookDelivery]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [WebhookDelivery]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WebhookDelivery>> upsert(
    _is.DatabaseSession session,
    List<WebhookDelivery> rows, {
    required _is.ColumnSelections<WebhookDeliveryTable> conflictColumns,
    _is.ColumnSelections<WebhookDeliveryTable>? updateColumns,
    _is.WhereExpressionBuilder<WebhookDeliveryTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<WebhookDelivery>(
      rows,
      conflictColumns: conflictColumns(WebhookDelivery.t),
      updateColumns: updateColumns?.call(WebhookDelivery.t),
      updateWhere: updateWhere?.call(WebhookDelivery.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [WebhookDelivery] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [WebhookDelivery] will have its `id` field set.
  Future<WebhookDelivery?> upsertRow(
    _is.DatabaseSession session,
    WebhookDelivery row, {
    required _is.ColumnSelections<WebhookDeliveryTable> conflictColumns,
    _is.ColumnSelections<WebhookDeliveryTable>? updateColumns,
    _is.WhereExpressionBuilder<WebhookDeliveryTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<WebhookDelivery>(
      row,
      conflictColumns: conflictColumns(WebhookDelivery.t),
      updateColumns: updateColumns?.call(WebhookDelivery.t),
      updateWhere: updateWhere?.call(WebhookDelivery.t),
      transaction: transaction,
    );
  }

  /// Updates all [WebhookDelivery]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WebhookDelivery>> update(
    _is.DatabaseSession session,
    List<WebhookDelivery> rows, {
    _is.ColumnSelections<WebhookDeliveryTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<WebhookDelivery>(
      rows,
      columns: columns?.call(WebhookDelivery.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [WebhookDelivery]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WebhookDelivery> updateRow(
    _is.DatabaseSession session,
    WebhookDelivery row, {
    _is.ColumnSelections<WebhookDeliveryTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<WebhookDelivery>(
      row,
      columns: columns?.call(WebhookDelivery.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WebhookDelivery] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<WebhookDelivery?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<WebhookDeliveryUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<WebhookDelivery>(
      id,
      columnValues: columnValues(WebhookDelivery.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WebhookDelivery]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WebhookDelivery>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<WebhookDeliveryUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<WebhookDeliveryTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WebhookDeliveryTable>? orderBy,
    _is.OrderByListBuilder<WebhookDeliveryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<WebhookDelivery>(
      columnValues: columnValues(WebhookDelivery.t.updateTable),
      where: where(WebhookDelivery.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WebhookDelivery.t),
      orderByList: orderByList?.call(WebhookDelivery.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [WebhookDelivery]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WebhookDelivery>> delete(
    _is.DatabaseSession session,
    List<WebhookDelivery> rows, {
    _is.OrderByBuilder<WebhookDeliveryTable>? orderBy,
    _is.OrderByListBuilder<WebhookDeliveryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<WebhookDelivery>(
      rows,
      orderBy: orderBy?.call(WebhookDelivery.t),
      orderByList: orderByList?.call(WebhookDelivery.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [WebhookDelivery].
  Future<WebhookDelivery> deleteRow(
    _is.DatabaseSession session,
    WebhookDelivery row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WebhookDelivery>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WebhookDelivery>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WebhookDeliveryTable> where,
    _is.OrderByBuilder<WebhookDeliveryTable>? orderBy,
    _is.OrderByListBuilder<WebhookDeliveryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<WebhookDelivery>(
      where: where(WebhookDelivery.t),
      orderBy: orderBy?.call(WebhookDelivery.t),
      orderByList: orderByList?.call(WebhookDelivery.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WebhookDeliveryTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<WebhookDelivery>(
      where: where?.call(WebhookDelivery.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [WebhookDelivery] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WebhookDeliveryTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<WebhookDelivery>(
      where: where(WebhookDelivery.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
