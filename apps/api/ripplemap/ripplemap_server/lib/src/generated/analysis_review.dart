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

abstract class AnalysisReview
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = AnalysisReviewTable();

  static const db = AnalysisReviewRepository._();

  @override
  int? id;

  String authUserId;

  String jobKey;

  String decision;

  String? note;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AnalysisReview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static AnalysisReviewInclude include() {
    return AnalysisReviewInclude._();
  }

  static AnalysisReviewIncludeList includeList({
    _is.WhereExpressionBuilder<AnalysisReviewTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AnalysisReviewTable>? orderBy,
    _is.OrderByListBuilder<AnalysisReviewTable>? orderByList,
    AnalysisReviewInclude? include,
  }) {
    return AnalysisReviewIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AnalysisReview.t),
      orderByList: orderByList?.call(AnalysisReview.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class AnalysisReviewUpdateTable extends _is.UpdateTable<AnalysisReviewTable> {
  AnalysisReviewUpdateTable(super.table);

  _is.ColumnValue<String, String> authUserId(String value) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> jobKey(String value) => _is.ColumnValue(
    table.jobKey,
    value,
  );

  _is.ColumnValue<String, String> decision(String value) => _is.ColumnValue(
    table.decision,
    value,
  );

  _is.ColumnValue<String, String> note(String? value) => _is.ColumnValue(
    table.note,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class AnalysisReviewTable extends _is.Table<int?> {
  AnalysisReviewTable({super.tableRelation})
    : super(tableName: 'analysis_review') {
    updateTable = AnalysisReviewUpdateTable(this);
    authUserId = _is.ColumnString(
      'authUserId',
      this,
    );
    jobKey = _is.ColumnString(
      'jobKey',
      this,
    );
    decision = _is.ColumnString(
      'decision',
      this,
    );
    note = _is.ColumnString(
      'note',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final AnalysisReviewUpdateTable updateTable;

  late final _is.ColumnString authUserId;

  late final _is.ColumnString jobKey;

  late final _is.ColumnString decision;

  late final _is.ColumnString note;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    authUserId,
    jobKey,
    decision,
    note,
    updatedAt,
  ];
}

class AnalysisReviewInclude extends _is.IncludeObject {
  AnalysisReviewInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AnalysisReview.t;
}

class AnalysisReviewIncludeList extends _is.IncludeList {
  AnalysisReviewIncludeList._({
    _is.WhereExpressionBuilder<AnalysisReviewTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AnalysisReview.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AnalysisReview.t;
}

class AnalysisReviewRepository {
  const AnalysisReviewRepository._();

  /// Returns a list of [AnalysisReview]s matching the given query parameters.
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
  Future<List<AnalysisReview>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AnalysisReviewTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AnalysisReviewTable>? orderBy,
    _is.OrderByListBuilder<AnalysisReviewTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AnalysisReview>(
      where: where?.call(AnalysisReview.t),
      orderBy: orderBy?.call(AnalysisReview.t),
      orderByList: orderByList?.call(AnalysisReview.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AnalysisReview] matching the given query parameters.
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
  Future<AnalysisReview?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AnalysisReviewTable>? where,
    int? offset,
    _is.OrderByBuilder<AnalysisReviewTable>? orderBy,
    _is.OrderByListBuilder<AnalysisReviewTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AnalysisReview>(
      where: where?.call(AnalysisReview.t),
      orderBy: orderBy?.call(AnalysisReview.t),
      orderByList: orderByList?.call(AnalysisReview.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AnalysisReview] by its [id] or null if no such row exists.
  Future<AnalysisReview?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AnalysisReview>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AnalysisReview]s in the list and returns the inserted rows.
  ///
  /// The returned [AnalysisReview]s will have their `id` fields set.
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
  Future<List<AnalysisReview>> insert(
    _is.DatabaseSession session,
    List<AnalysisReview> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AnalysisReview>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AnalysisReview] and returns the inserted row.
  ///
  /// The returned [AnalysisReview] will have its `id` field set.
  Future<AnalysisReview> insertRow(
    _is.DatabaseSession session,
    AnalysisReview row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AnalysisReview>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AnalysisReview]s in the list and returns the resulting rows.
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
  /// The returned [AnalysisReview]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AnalysisReview>> upsert(
    _is.DatabaseSession session,
    List<AnalysisReview> rows, {
    required _is.ColumnSelections<AnalysisReviewTable> conflictColumns,
    _is.ColumnSelections<AnalysisReviewTable>? updateColumns,
    _is.WhereExpressionBuilder<AnalysisReviewTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AnalysisReview>(
      rows,
      conflictColumns: conflictColumns(AnalysisReview.t),
      updateColumns: updateColumns?.call(AnalysisReview.t),
      updateWhere: updateWhere?.call(AnalysisReview.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AnalysisReview] and returns the resulting row.
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
  /// The returned [AnalysisReview] will have its `id` field set.
  Future<AnalysisReview?> upsertRow(
    _is.DatabaseSession session,
    AnalysisReview row, {
    required _is.ColumnSelections<AnalysisReviewTable> conflictColumns,
    _is.ColumnSelections<AnalysisReviewTable>? updateColumns,
    _is.WhereExpressionBuilder<AnalysisReviewTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AnalysisReview>(
      row,
      conflictColumns: conflictColumns(AnalysisReview.t),
      updateColumns: updateColumns?.call(AnalysisReview.t),
      updateWhere: updateWhere?.call(AnalysisReview.t),
      transaction: transaction,
    );
  }

  /// Updates all [AnalysisReview]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AnalysisReview>> update(
    _is.DatabaseSession session,
    List<AnalysisReview> rows, {
    _is.ColumnSelections<AnalysisReviewTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AnalysisReview>(
      rows,
      columns: columns?.call(AnalysisReview.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AnalysisReview]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AnalysisReview> updateRow(
    _is.DatabaseSession session,
    AnalysisReview row, {
    _is.ColumnSelections<AnalysisReviewTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AnalysisReview>(
      row,
      columns: columns?.call(AnalysisReview.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AnalysisReview] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AnalysisReview?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AnalysisReviewUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AnalysisReview>(
      id,
      columnValues: columnValues(AnalysisReview.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AnalysisReview]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AnalysisReview>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AnalysisReviewUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AnalysisReviewTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AnalysisReviewTable>? orderBy,
    _is.OrderByListBuilder<AnalysisReviewTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AnalysisReview>(
      columnValues: columnValues(AnalysisReview.t.updateTable),
      where: where(AnalysisReview.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AnalysisReview.t),
      orderByList: orderByList?.call(AnalysisReview.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AnalysisReview]s in the list and returns the deleted rows.
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
  Future<List<AnalysisReview>> delete(
    _is.DatabaseSession session,
    List<AnalysisReview> rows, {
    _is.OrderByBuilder<AnalysisReviewTable>? orderBy,
    _is.OrderByListBuilder<AnalysisReviewTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AnalysisReview>(
      rows,
      orderBy: orderBy?.call(AnalysisReview.t),
      orderByList: orderByList?.call(AnalysisReview.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AnalysisReview].
  Future<AnalysisReview> deleteRow(
    _is.DatabaseSession session,
    AnalysisReview row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AnalysisReview>(
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
  Future<List<AnalysisReview>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AnalysisReviewTable> where,
    _is.OrderByBuilder<AnalysisReviewTable>? orderBy,
    _is.OrderByListBuilder<AnalysisReviewTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AnalysisReview>(
      where: where(AnalysisReview.t),
      orderBy: orderBy?.call(AnalysisReview.t),
      orderByList: orderByList?.call(AnalysisReview.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AnalysisReviewTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AnalysisReview>(
      where: where?.call(AnalysisReview.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AnalysisReview] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AnalysisReviewTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AnalysisReview>(
      where: where(AnalysisReview.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
