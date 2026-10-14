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

abstract class AnalysisJob
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = AnalysisJobTable();

  static const db = AnalysisJobRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AnalysisJob]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static AnalysisJobInclude include() {
    return AnalysisJobInclude._();
  }

  static AnalysisJobIncludeList includeList({
    _is.WhereExpressionBuilder<AnalysisJobTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AnalysisJobTable>? orderBy,
    _is.OrderByListBuilder<AnalysisJobTable>? orderByList,
    AnalysisJobInclude? include,
  }) {
    return AnalysisJobIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AnalysisJob.t),
      orderByList: orderByList?.call(AnalysisJob.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class AnalysisJobUpdateTable extends _is.UpdateTable<AnalysisJobTable> {
  AnalysisJobUpdateTable(super.table);

  _is.ColumnValue<String, String> jobKey(String value) => _is.ColumnValue(
    table.jobKey,
    value,
  );

  _is.ColumnValue<String, String> sessionId(String? value) => _is.ColumnValue(
    table.sessionId,
    value,
  );

  _is.ColumnValue<String, String> authUserId(String? value) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> owner(String value) => _is.ColumnValue(
    table.owner,
    value,
  );

  _is.ColumnValue<String, String> repository(String value) => _is.ColumnValue(
    table.repository,
    value,
  );

  _is.ColumnValue<int, int> pullRequestNumber(int value) => _is.ColumnValue(
    table.pullRequestNumber,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> reportJson(String? value) => _is.ColumnValue(
    table.reportJson,
    value,
  );

  _is.ColumnValue<String, String> errorMessage(String? value) =>
      _is.ColumnValue(
        table.errorMessage,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class AnalysisJobTable extends _is.Table<int?> {
  AnalysisJobTable({super.tableRelation}) : super(tableName: 'analysis_job') {
    updateTable = AnalysisJobUpdateTable(this);
    jobKey = _is.ColumnString(
      'jobKey',
      this,
    );
    sessionId = _is.ColumnString(
      'sessionId',
      this,
    );
    authUserId = _is.ColumnString(
      'authUserId',
      this,
    );
    owner = _is.ColumnString(
      'owner',
      this,
    );
    repository = _is.ColumnString(
      'repository',
      this,
    );
    pullRequestNumber = _is.ColumnInt(
      'pullRequestNumber',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    reportJson = _is.ColumnString(
      'reportJson',
      this,
    );
    errorMessage = _is.ColumnString(
      'errorMessage',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final AnalysisJobUpdateTable updateTable;

  late final _is.ColumnString jobKey;

  late final _is.ColumnString sessionId;

  late final _is.ColumnString authUserId;

  late final _is.ColumnString owner;

  late final _is.ColumnString repository;

  late final _is.ColumnInt pullRequestNumber;

  late final _is.ColumnString status;

  late final _is.ColumnString reportJson;

  late final _is.ColumnString errorMessage;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    jobKey,
    sessionId,
    authUserId,
    owner,
    repository,
    pullRequestNumber,
    status,
    reportJson,
    errorMessage,
    createdAt,
    updatedAt,
  ];
}

class AnalysisJobInclude extends _is.IncludeObject {
  AnalysisJobInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AnalysisJob.t;
}

class AnalysisJobIncludeList extends _is.IncludeList {
  AnalysisJobIncludeList._({
    _is.WhereExpressionBuilder<AnalysisJobTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AnalysisJob.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AnalysisJob.t;
}

class AnalysisJobRepository {
  const AnalysisJobRepository._();

  /// Returns a list of [AnalysisJob]s matching the given query parameters.
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
  Future<List<AnalysisJob>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AnalysisJobTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AnalysisJobTable>? orderBy,
    _is.OrderByListBuilder<AnalysisJobTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AnalysisJob>(
      where: where?.call(AnalysisJob.t),
      orderBy: orderBy?.call(AnalysisJob.t),
      orderByList: orderByList?.call(AnalysisJob.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AnalysisJob] matching the given query parameters.
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
  Future<AnalysisJob?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AnalysisJobTable>? where,
    int? offset,
    _is.OrderByBuilder<AnalysisJobTable>? orderBy,
    _is.OrderByListBuilder<AnalysisJobTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AnalysisJob>(
      where: where?.call(AnalysisJob.t),
      orderBy: orderBy?.call(AnalysisJob.t),
      orderByList: orderByList?.call(AnalysisJob.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AnalysisJob] by its [id] or null if no such row exists.
  Future<AnalysisJob?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AnalysisJob>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AnalysisJob]s in the list and returns the inserted rows.
  ///
  /// The returned [AnalysisJob]s will have their `id` fields set.
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
  Future<List<AnalysisJob>> insert(
    _is.DatabaseSession session,
    List<AnalysisJob> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AnalysisJob>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AnalysisJob] and returns the inserted row.
  ///
  /// The returned [AnalysisJob] will have its `id` field set.
  Future<AnalysisJob> insertRow(
    _is.DatabaseSession session,
    AnalysisJob row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AnalysisJob>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AnalysisJob]s in the list and returns the resulting rows.
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
  /// The returned [AnalysisJob]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AnalysisJob>> upsert(
    _is.DatabaseSession session,
    List<AnalysisJob> rows, {
    required _is.ColumnSelections<AnalysisJobTable> conflictColumns,
    _is.ColumnSelections<AnalysisJobTable>? updateColumns,
    _is.WhereExpressionBuilder<AnalysisJobTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AnalysisJob>(
      rows,
      conflictColumns: conflictColumns(AnalysisJob.t),
      updateColumns: updateColumns?.call(AnalysisJob.t),
      updateWhere: updateWhere?.call(AnalysisJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AnalysisJob] and returns the resulting row.
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
  /// The returned [AnalysisJob] will have its `id` field set.
  Future<AnalysisJob?> upsertRow(
    _is.DatabaseSession session,
    AnalysisJob row, {
    required _is.ColumnSelections<AnalysisJobTable> conflictColumns,
    _is.ColumnSelections<AnalysisJobTable>? updateColumns,
    _is.WhereExpressionBuilder<AnalysisJobTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AnalysisJob>(
      row,
      conflictColumns: conflictColumns(AnalysisJob.t),
      updateColumns: updateColumns?.call(AnalysisJob.t),
      updateWhere: updateWhere?.call(AnalysisJob.t),
      transaction: transaction,
    );
  }

  /// Updates all [AnalysisJob]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AnalysisJob>> update(
    _is.DatabaseSession session,
    List<AnalysisJob> rows, {
    _is.ColumnSelections<AnalysisJobTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AnalysisJob>(
      rows,
      columns: columns?.call(AnalysisJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AnalysisJob]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AnalysisJob> updateRow(
    _is.DatabaseSession session,
    AnalysisJob row, {
    _is.ColumnSelections<AnalysisJobTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AnalysisJob>(
      row,
      columns: columns?.call(AnalysisJob.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AnalysisJob] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AnalysisJob?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AnalysisJobUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AnalysisJob>(
      id,
      columnValues: columnValues(AnalysisJob.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AnalysisJob]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AnalysisJob>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AnalysisJobUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AnalysisJobTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AnalysisJobTable>? orderBy,
    _is.OrderByListBuilder<AnalysisJobTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AnalysisJob>(
      columnValues: columnValues(AnalysisJob.t.updateTable),
      where: where(AnalysisJob.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AnalysisJob.t),
      orderByList: orderByList?.call(AnalysisJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AnalysisJob]s in the list and returns the deleted rows.
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
  Future<List<AnalysisJob>> delete(
    _is.DatabaseSession session,
    List<AnalysisJob> rows, {
    _is.OrderByBuilder<AnalysisJobTable>? orderBy,
    _is.OrderByListBuilder<AnalysisJobTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AnalysisJob>(
      rows,
      orderBy: orderBy?.call(AnalysisJob.t),
      orderByList: orderByList?.call(AnalysisJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AnalysisJob].
  Future<AnalysisJob> deleteRow(
    _is.DatabaseSession session,
    AnalysisJob row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AnalysisJob>(
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
  Future<List<AnalysisJob>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AnalysisJobTable> where,
    _is.OrderByBuilder<AnalysisJobTable>? orderBy,
    _is.OrderByListBuilder<AnalysisJobTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AnalysisJob>(
      where: where(AnalysisJob.t),
      orderBy: orderBy?.call(AnalysisJob.t),
      orderByList: orderByList?.call(AnalysisJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AnalysisJobTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AnalysisJob>(
      where: where?.call(AnalysisJob.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AnalysisJob] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AnalysisJobTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AnalysisJob>(
      where: where(AnalysisJob.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
