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

abstract class GitHubConnection
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = GitHubConnectionTable();

  static const db = GitHubConnectionRepository._();

  @override
  int? id;

  String? sessionId;

  String? authUserId;

  String githubLogin;

  String encryptedAccessToken;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [GitHubConnection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static GitHubConnectionInclude include() {
    return GitHubConnectionInclude._();
  }

  static GitHubConnectionIncludeList includeList({
    _is.WhereExpressionBuilder<GitHubConnectionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GitHubConnectionTable>? orderBy,
    _is.OrderByListBuilder<GitHubConnectionTable>? orderByList,
    GitHubConnectionInclude? include,
  }) {
    return GitHubConnectionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GitHubConnection.t),
      orderByList: orderByList?.call(GitHubConnection.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class GitHubConnectionUpdateTable
    extends _is.UpdateTable<GitHubConnectionTable> {
  GitHubConnectionUpdateTable(super.table);

  _is.ColumnValue<String, String> sessionId(String? value) => _is.ColumnValue(
    table.sessionId,
    value,
  );

  _is.ColumnValue<String, String> authUserId(String? value) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> githubLogin(String value) => _is.ColumnValue(
    table.githubLogin,
    value,
  );

  _is.ColumnValue<String, String> encryptedAccessToken(String value) =>
      _is.ColumnValue(
        table.encryptedAccessToken,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class GitHubConnectionTable extends _is.Table<int?> {
  GitHubConnectionTable({super.tableRelation})
    : super(tableName: 'github_connection') {
    updateTable = GitHubConnectionUpdateTable(this);
    sessionId = _is.ColumnString(
      'sessionId',
      this,
    );
    authUserId = _is.ColumnString(
      'authUserId',
      this,
    );
    githubLogin = _is.ColumnString(
      'githubLogin',
      this,
    );
    encryptedAccessToken = _is.ColumnString(
      'encryptedAccessToken',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final GitHubConnectionUpdateTable updateTable;

  late final _is.ColumnString sessionId;

  late final _is.ColumnString authUserId;

  late final _is.ColumnString githubLogin;

  late final _is.ColumnString encryptedAccessToken;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    sessionId,
    authUserId,
    githubLogin,
    encryptedAccessToken,
    createdAt,
  ];
}

class GitHubConnectionInclude extends _is.IncludeObject {
  GitHubConnectionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => GitHubConnection.t;
}

class GitHubConnectionIncludeList extends _is.IncludeList {
  GitHubConnectionIncludeList._({
    _is.WhereExpressionBuilder<GitHubConnectionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GitHubConnection.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => GitHubConnection.t;
}

class GitHubConnectionRepository {
  const GitHubConnectionRepository._();

  /// Returns a list of [GitHubConnection]s matching the given query parameters.
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
  Future<List<GitHubConnection>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GitHubConnectionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GitHubConnectionTable>? orderBy,
    _is.OrderByListBuilder<GitHubConnectionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GitHubConnection>(
      where: where?.call(GitHubConnection.t),
      orderBy: orderBy?.call(GitHubConnection.t),
      orderByList: orderByList?.call(GitHubConnection.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GitHubConnection] matching the given query parameters.
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
  Future<GitHubConnection?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GitHubConnectionTable>? where,
    int? offset,
    _is.OrderByBuilder<GitHubConnectionTable>? orderBy,
    _is.OrderByListBuilder<GitHubConnectionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GitHubConnection>(
      where: where?.call(GitHubConnection.t),
      orderBy: orderBy?.call(GitHubConnection.t),
      orderByList: orderByList?.call(GitHubConnection.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GitHubConnection] by its [id] or null if no such row exists.
  Future<GitHubConnection?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GitHubConnection>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GitHubConnection]s in the list and returns the inserted rows.
  ///
  /// The returned [GitHubConnection]s will have their `id` fields set.
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
  Future<List<GitHubConnection>> insert(
    _is.DatabaseSession session,
    List<GitHubConnection> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<GitHubConnection>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [GitHubConnection] and returns the inserted row.
  ///
  /// The returned [GitHubConnection] will have its `id` field set.
  Future<GitHubConnection> insertRow(
    _is.DatabaseSession session,
    GitHubConnection row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<GitHubConnection>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [GitHubConnection]s in the list and returns the resulting rows.
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
  /// The returned [GitHubConnection]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GitHubConnection>> upsert(
    _is.DatabaseSession session,
    List<GitHubConnection> rows, {
    required _is.ColumnSelections<GitHubConnectionTable> conflictColumns,
    _is.ColumnSelections<GitHubConnectionTable>? updateColumns,
    _is.WhereExpressionBuilder<GitHubConnectionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<GitHubConnection>(
      rows,
      conflictColumns: conflictColumns(GitHubConnection.t),
      updateColumns: updateColumns?.call(GitHubConnection.t),
      updateWhere: updateWhere?.call(GitHubConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [GitHubConnection] and returns the resulting row.
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
  /// The returned [GitHubConnection] will have its `id` field set.
  Future<GitHubConnection?> upsertRow(
    _is.DatabaseSession session,
    GitHubConnection row, {
    required _is.ColumnSelections<GitHubConnectionTable> conflictColumns,
    _is.ColumnSelections<GitHubConnectionTable>? updateColumns,
    _is.WhereExpressionBuilder<GitHubConnectionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<GitHubConnection>(
      row,
      conflictColumns: conflictColumns(GitHubConnection.t),
      updateColumns: updateColumns?.call(GitHubConnection.t),
      updateWhere: updateWhere?.call(GitHubConnection.t),
      transaction: transaction,
    );
  }

  /// Updates all [GitHubConnection]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GitHubConnection>> update(
    _is.DatabaseSession session,
    List<GitHubConnection> rows, {
    _is.ColumnSelections<GitHubConnectionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<GitHubConnection>(
      rows,
      columns: columns?.call(GitHubConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [GitHubConnection]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GitHubConnection> updateRow(
    _is.DatabaseSession session,
    GitHubConnection row, {
    _is.ColumnSelections<GitHubConnectionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<GitHubConnection>(
      row,
      columns: columns?.call(GitHubConnection.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GitHubConnection] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GitHubConnection?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<GitHubConnectionUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<GitHubConnection>(
      id,
      columnValues: columnValues(GitHubConnection.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GitHubConnection]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GitHubConnection>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<GitHubConnectionUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<GitHubConnectionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GitHubConnectionTable>? orderBy,
    _is.OrderByListBuilder<GitHubConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<GitHubConnection>(
      columnValues: columnValues(GitHubConnection.t.updateTable),
      where: where(GitHubConnection.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GitHubConnection.t),
      orderByList: orderByList?.call(GitHubConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [GitHubConnection]s in the list and returns the deleted rows.
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
  Future<List<GitHubConnection>> delete(
    _is.DatabaseSession session,
    List<GitHubConnection> rows, {
    _is.OrderByBuilder<GitHubConnectionTable>? orderBy,
    _is.OrderByListBuilder<GitHubConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<GitHubConnection>(
      rows,
      orderBy: orderBy?.call(GitHubConnection.t),
      orderByList: orderByList?.call(GitHubConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [GitHubConnection].
  Future<GitHubConnection> deleteRow(
    _is.DatabaseSession session,
    GitHubConnection row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GitHubConnection>(
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
  Future<List<GitHubConnection>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GitHubConnectionTable> where,
    _is.OrderByBuilder<GitHubConnectionTable>? orderBy,
    _is.OrderByListBuilder<GitHubConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<GitHubConnection>(
      where: where(GitHubConnection.t),
      orderBy: orderBy?.call(GitHubConnection.t),
      orderByList: orderByList?.call(GitHubConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GitHubConnectionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<GitHubConnection>(
      where: where?.call(GitHubConnection.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GitHubConnection] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GitHubConnectionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GitHubConnection>(
      where: where(GitHubConnection.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
