/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../../flutter_ui.dart';
import '../../../../../model/data/column_definition.dart';
import '../../../../../model/data/data_book.dart';
import '../../../../../model/data/filter_condition.dart';
import '../../../../../util/i_types.dart';
import '../../../../config/i_config_service.dart';

/// Manages the offline database, has to be closed with [close].
///
/// Table and column names are escaped via double quotes.<br>
/// See <https://www.sqlite.org/lang_keywords.html>
class OfflineDatabase {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Table with information for each saved app.
  static const OFFLINE_APPS_TABLE = "jvx_offline_apps";

  /// Table which contains metadata for offline tables, has a foreign key to [OFFLINE_APPS_TABLE].
  static const OFFLINE_METADATA_TABLE = "jvx_offline_metadata";

  /// Prefix for offline columns.
  static const COLUMN_PREFIX = r"$OLD$_";

  /// Column name for the state column.
  static const STATE_COLUMN = r'$STATE$';

  /// Inserted state for column
  static const ROW_STATE_INSERTED = "I";

  /// Updated state for column
  static const ROW_STATE_UPDATED = "U";

  /// Deleted state for column
  static const ROW_STATE_DELETED = "D";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Instance of sqflite database
  late Database db;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OfflineDatabase._();

  /// Creates and optionally initializes the database.
  static Future<OfflineDatabase> open() async {
    var offlineDatabase = OfflineDatabase._();
    await offlineDatabase.init();
    return offlineDatabase;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Init and define Database
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the database and creates structure tables.
  init() async {
    // Avoid errors caused by flutter upgrade.
    WidgetsFlutterBinding.ensureInitialized();

    String? dbpath = join(await getDatabasesPath(), "jvx_offline_data.sqlite");

    if (kDebugMode) {
      print("Database path: $dbpath");
    }

    // Open the database and store the reference.
    db = await openDatabase(
      // Set the path to the database.
      dbpath,
      onUpgrade: (db, oldVersion, newVersion) => _createStructTables(db),
      // Set the version. This executes the onCreate/onUpgrade function and provides a
      // path to perform database upgrades and downgrades.
      // We don't check the app_version here, but if it's a problem in the future, we could do a check
      version: 1,
    );
  }

  /// Creates metadata tables, [OFFLINE_APPS_TABLE] and [OFFLINE_METADATA_TABLE].
  Future<void> _createStructTables(Database db) async {
    String createAppsTableSQL = """
CREATE TABLE IF NOT EXISTS $OFFLINE_APPS_TABLE (
   ID INTEGER PRIMARY KEY,
   APP TEXT NOT NULL UNIQUE
);""";
    await db.execute(createAppsTableSQL);

    String createMetaDataTablesSQL = """
CREATE TABLE IF NOT EXISTS $OFFLINE_METADATA_TABLE (
   ID INTEGER PRIMARY KEY,
   APP_ID INTEGER NOT NULL,
   DATA_PROVIDER TEXT NOT NULL,
   TABLE_NAME TEXT NOT NULL,
   META_DATA TEXT NOT NULL,
   FOREIGN KEY(APP_ID) REFERENCES $OFFLINE_APPS_TABLE(ID) ON UPDATE CASCADE ON DELETE CASCADE
);""";
    await db.execute(createMetaDataTablesSQL);
  }

  /// Returns the `APP_ID` from [OFFLINE_APPS_TABLE].
  Future<int?> _queryAppId(String appName, {Transaction? txn}) async {
    return (txn ?? db).query(
      OFFLINE_APPS_TABLE,
      where: "APP LIKE ?",
      whereArgs: [appName],
      columns: ["ID"],
    ).then((value) => value.firstOrNull?["ID"] as int?);
  }

  /// Creates offline tables for offline data.
  ///
  /// Uses a [Transaction] and [Batch] to efficiently execute and gracefully fail in case of an error.
  Future<void> createTables(
    String appKey,
    List<DalMetaData> dalMetaData,
  ) {
    return db.transaction((txn) async {
      Batch batch = txn.batch();

      int appId = await txn.insert(OFFLINE_APPS_TABLE, {"APP": appKey});
      await _fillStructTables(appId, dalMetaData, batch: batch);
      dalMetaData.forEach((table) => _createDataTable(table, batch: batch));

      await batch.commit(noResult: true);
    });
  }

  /// Creates metadata entries for offline tables.
  Future<void> _fillStructTables(
    int appId,
    List<DalMetaData> dalMetaData, {
    required Batch batch,
  }) async {
    dalMetaData.forEach((metaData) => batch.insert(
          OFFLINE_METADATA_TABLE,
          {
            "APP_ID": appId,
            "DATA_PROVIDER": metaData.dataProvider,
            "TABLE_NAME": formatOfflineTableName(metaData.dataProvider),
            "META_DATA": jsonEncode(metaData.toJson()),
          },
        ));
  }

  void _createDataTable(DalMetaData table, {required Batch batch}) {
    String createTableSQL = _buildCreateTableSQL(table);
    FlutterUI.logAPI.d("Create Table SQL:\n$createTableSQL");
    // Run the CREATE TABLE statement on the database.
    batch.execute(createTableSQL);
  }

  /// Drops all [DalMetaData.dataProvider] tables and removes all metadata entries from the current app.
  ///
  /// Uses a [Transaction] and [Batch] to efficiently execute and gracefully fail in case of an error.
  Future<dynamic> dropTables(String appKey) {
    return db.transaction((txn) async {
      Batch batch = txn.batch();

      int? appId = await _queryAppId(appKey, txn: txn);

      if (appId != null) {
        List<Map<String, Object?>> rows = await txn.query(
          OFFLINE_METADATA_TABLE,
          columns: ['TABLE_NAME'],
          where: "APP_ID = ?",
          whereArgs: [appId],
        );

        _dropDataTables(rows, batch: batch);
      }

      _clearStructTables(appId, batch: batch);

      await batch.commit(noResult: true);
    });
  }

  /// Drops all data tables using [rows].
  void _dropDataTables(List<Map<String, Object?>> rows, {required Batch batch}) {
    for (Map<String, Object?> row in rows) {
      batch.execute('DROP TABLE IF EXISTS "${row["TABLE_NAME"]}";');
    }
  }

  /// Removes all metadata entries of this [appId] from [OFFLINE_METADATA_TABLE] and [OFFLINE_APPS_TABLE].
  void _clearStructTables(int? appId, {required Batch batch}) {
    if (appId != null) {
      batch.delete(OFFLINE_METADATA_TABLE, where: "APP_ID = ?", whereArgs: [appId]);
      batch.delete(OFFLINE_APPS_TABLE, where: "ID = ?", whereArgs: [appId]);
    }
  }

  /// Retrieves all saved [DalMetaData]s from [OFFLINE_APPS_TABLE].
  Future<List<DalMetaData>> getMetaData(String appId, {String? pDataProvider, Transaction? txn}) {
    List<String> whereArgs = [appId];
    if (pDataProvider != null) {
      whereArgs.add(pDataProvider);
    }
    return db
        .query(
          OFFLINE_METADATA_TABLE,
          columns: ['META_DATA'],
          where:
              "APP_ID = (SELECT ID FROM $OFFLINE_APPS_TABLE WHERE APP LIKE ?)${pDataProvider != null ? " AND DATA_PROVIDER LIKE ?" : ""}",
          whereArgs: whereArgs,
        )
        .then((result) =>
            result.map((e) => DalMetaData.fromJson(jsonDecode(e['META_DATA'] as String))).toList(growable: false));
  }

  /// Closes the database.
  Future<void> close() {
    return db.close();
  }

  /// Whether this database is currently closed.
  bool isClosed() {
    return !db.isOpen;
  }

  /// Constructs the identifier for the offline table by replacing all non-word characters with '_'.
  String formatOfflineTableName(String tableName) {
    return tableName.replaceAll(RegExp(r"[^\w_]"), "_");
  }

  /// Constructs the identifier for the offline column by using [COLUMN_PREFIX].
  String formatOfflineColumnName(String columnName) {
    return COLUMN_PREFIX + columnName;
  }

  /// Builds a SQL command to create an offline table on the basis of [pTable].
  String _buildCreateTableSQL(DalMetaData pTable) {
    var sql = StringBuffer('CREATE TABLE "${formatOfflineTableName(pTable.dataProvider)}" (');

    for (var column in pTable.columnDefinitions) {
      sql.write(_buildCreateColumnSQL(column.name, column));
      // Offline/Old columns are always nullable.
      sql.write(_buildCreateColumnSQL(formatOfflineColumnName(column.name), column, nullable: true));
    }
    sql.write('"$STATE_COLUMN" TEXT\n');

    sql.write(");");
    return sql.toString();
  }

  /// Builds a SQL command to create a column on the basis of [pColumn].
  ///
  /// [nullable] is currently ignored, therefore every column is nullable, could be completely dropped in a future release.
  String _buildCreateColumnSQL(String pColumnName, ColumnDefinition pColumn, {bool? nullable}) {
    var columnDef = StringBuffer('"$pColumnName" ');
    columnDef.write(Types.convertToSQLite(pColumn.dataTypeIdentifier, scale: pColumn.scale));

    // TODO Check default value

    if (IConfigService().getAppConfig()?.offlineConfig!.checkConstraints ?? true) {
      if (pColumn.length != null) {
        columnDef.write(' CHECK(length("$pColumnName") <= ${pColumn.length})');
      }

      if (pColumn.precision != null) {
        columnDef.write(' CHECK("$pColumnName" = ROUND("$pColumnName", ${pColumn.precision}))');
      }

      if (!(pColumn.signed ?? true)) {
        columnDef.write(' CHECK("$pColumnName") >= 0)');
      }
    }

    columnDef.write(",\n");
    return columnDef.toString();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Table management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Whether a table named [pTableName] exists.
  ///
  /// The table name is escaped using [formatOfflineTableName].
  Future<bool> tableExists(String pTableName, {Transaction? txn}) {
    return _tableExists(formatOfflineTableName(pTableName), txn: txn);
  }

  /// Whether a table named [tableName] exists.
  Future<bool> _tableExists(String tableName, {Transaction? txn}) {
    String sql = 'SELECT COUNT(*) AS COUNT FROM sqlite_master WHERE TYPE = \'table\' AND NAME = ?;';
    return db.rawQuery(sql, [tableName])
        // Check if returned count in select is 1
        .then((results) => results[0]['COUNT'] as int > 0);
  }

  /// Drops a table named [pTableName], if it exists.
  ///
  /// The table name is escaped using [formatOfflineTableName].
  Future<void> dropTable(String pTableName, {Transaction? txn}) {
    return _dropTable(formatOfflineTableName(pTableName), txn: txn);
  }

  /// Drops a table named [tableName], if it exists.
  Future<void> _dropTable(String tableName, {Transaction? txn}) {
    return (txn ?? db).execute('DROP TABLE IF EXISTS "$tableName";');
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Row Management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Retrieves all rows from this [pDataProvider] where the [STATE_COLUMN] is not null.
  ///
  /// Returns an empty map if the table doesn't exist.
  Future<Map<String, List<Map<String, Object?>>>> getChangedRows(String pDataProvider, {Transaction? txn}) async {
    if (await tableExists(pDataProvider, txn: txn)) {
      return (txn ?? db)
          .query(formatOfflineTableName(pDataProvider), where: '"$STATE_COLUMN" IS NOT NULL')
          .then((value) => groupBy(value, (p0) => p0[STATE_COLUMN] as String));
    } else {
      return {};
    }
  }

  /// Resets all state columns for [pDataProvider]. (Sets all [STATE_COLUMN]s back to `null`)
  ///
  /// * If [pResetRow] is empty, returns `0` and does nothing.
  /// * If row in [pResetRow] contains no columns, it is skipped.
  /// * Otherwise the columns in [pResetRow] are used to create a where clause.
  Future<int> resetState(String pDataProvider, Map<String, Object?> pResetRow, {Transaction? txn}) {
    String where = "1 = 0";

    if (pResetRow.isNotEmpty) {
      where += " OR (";
      List<String> columns = [];
      for (var column in pResetRow.entries) {
        String s = '"${column.key}"';
        if (column.value != null) {
          s += " = ?";
        } else {
          s += " IS NULL";
        }
        columns.add(s);
      }
      where += "${columns.join(" AND ")})";
    }

    return (txn ?? db).update(
      formatOfflineTableName(pDataProvider),
      {'"$STATE_COLUMN"': null},
      where: where,
      whereArgs: pResetRow.values.whereType<Object>().toList(growable: false),
    );
  }

  /// Checks if at least one valid row (not marked as deleted) exists in [pTableName], optionally with [pFilter] applied.
  Future<bool> rowExists({required String pTableName, Map<String, dynamic>? pFilter, Transaction? txn}) {
    String sql = 'SELECT COUNT(*) AS COUNT FROM "${formatOfflineTableName(pTableName)}"';
    if (pFilter != null) {
      sql += " WHERE${pFilter.keys.map((key) => '"$key" = ?').join(" AND ")}";
      sql += ' AND "$STATE_COLUMN" != \'$ROW_STATE_DELETED\'';
    }

    return (txn ?? db).rawQuery(sql, [...?pFilter?.values]).then((results) => results[0]['COUNT'] as int > 0);
  }

  /// Executes a SQL SELECT COUNT query for [pTableName] and returns the number of valid rows found, optionally with [pFilter] applied.
  Future<int> getCount({required String pTableName, FilterCondition? pFilter, Transaction? txn}) {
    var where = _getWhere(pFilter);
    return (txn ?? db)
        .query(formatOfflineTableName(pTableName),
            columns: ["COUNT(*) AS COUNT"], where: where?[0], whereArgs: where?[1])
        .then((results) => results[0]['COUNT'] as int);
  }

  /// Executes a SQL SELECT query for [pTableName] and returns a list of the valid rows that were found.
  Future<List<Map<String, dynamic>>> select({
    required String pTableName,
    List<String>? pColumns,
    FilterCondition? pFilter,
    String? pGroupBy,
    String? pHaving,
    String? pOrderBy,
    int? pLimit,
    int? pOffset,
    Transaction? txn,
  }) {
    var where = _getWhere(pFilter);
    return (txn ?? db).query(
      formatOfflineTableName(pTableName),
      columns: pColumns,
      where: where?[0],
      whereArgs: where?[1],
      groupBy: pGroupBy,
      having: pHaving,
      orderBy: pOrderBy,
      // Workaround for https://github.com/tekartik/sqflite/issues/1018
      limit: pLimit ?? (pOffset != null ? -1 : null),
      offset: pOffset,
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // CUD Operations
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Executes a INSERT query for [pTableName], sets the state to [ROW_STATE_INSERTED] and returns the last inserted row ID.
  Future<int> insert({required String pTableName, required Map<String, dynamic> pInsert, Transaction? txn}) {
    pInsert['"$STATE_COLUMN"'] = ROW_STATE_INSERTED;
    return rawInsert(pTableName: pTableName, pInsert: pInsert, txn: txn);
  }

  /// Executes a SQL INSERT query for [pTableName] and returns the last inserted row ID.
  Future<int> rawInsert({required String pTableName, required Map<String, dynamic> pInsert, Transaction? txn}) {
    return (txn ?? db).insert(formatOfflineTableName(pTableName), pInsert);
  }

  /// Executes a SQL UPDATE query for [pTableName] and returns the number of changes made.
  ///
  /// It first checks if the [STATE_COLUMN] is already set:
  /// * If not, copies all values to their respective offline/old column and sets the state to [ROW_STATE_UPDATED].
  /// * Otherwise leaves the state be and just updates the values (Inserted stays Inserted, and etc.).
  ///
  /// ### Example on first update:
  ///
  /// Initial state:
  ///
  /// | age | $OLD$_age |
  /// |-----|-----------|
  /// | 5   | NULL      |
  ///
  /// [pUpdate]: `{age = 10}`
  /// * `UPDATE $OLD$_age = age`
  /// * `UPDATE age = 10`
  ///
  /// Updated state:
  ///
  /// | age | $OLD$_age |
  /// |-----|-----------|
  /// | 10  | 5         |
  ///
  /// Future updates are just updating the column, no changes to state or offline/old columns.
  Future<int> update({
    required String pTableName,
    required Map<String, dynamic> pUpdate,
    FilterCondition? pFilter,
  }) {
    var where = _getWhere(pFilter);
    var offlineTableName = formatOfflineTableName(pTableName);

    return db.transaction((txn) async {
      String? state = await _getState(offlineTableName, where: where, txn: txn);
      if (state == null) {
        // Hasn't been touched yet, copy values to $OLD$ columns
        List<String> tableColumns = await _getTableColumns(offlineTableName, txn: txn);

        Map<String, dynamic> updateColumns = {'"$STATE_COLUMN"': null};
        // Constructs "$OLD$_age = age"
        tableColumns.forEach((column) => updateColumns['"${formatOfflineColumnName(column)}"'] = '"$column"');

        await _updateOfflineColumns(
          txn,
          offlineTableName,
          updateColumns,
          where?[0],
          [ROW_STATE_UPDATED, ...?where?[1]],
        );
      }
      return txn.update(offlineTableName, pUpdate, where: where?[0], whereArgs: where?[1]);
    });
  }

  /// Updates all [updateColumns] in [tableName].
  ///
  /// [updateColumns.values] are supposed to be column names only.
  /// If you need to supply a value, use `null` and add it to [args].
  Future<void> _updateOfflineColumns(
    Transaction txn,
    String tableName,
    Map<String, dynamic> updateColumns,
    String? where,
    List<dynamic> args,
  ) async {
    String updateClause = updateColumns.entries.map((entry) => '${entry.key} = ${entry.value ?? "?"}').join(", ");
    await txn.rawUpdate('UPDATE "$tableName" SET $updateClause WHERE $where', args);
  }

  /// Executes a SQL DELETE query for [pTableName] and returns the number of changes made.
  ///
  /// It first checks if the [STATE_COLUMN] is:
  /// * [ROW_STATE_INSERTED], which then simply deletes the row.
  /// * [ROW_STATE_UPDATED], which rolls back all changes (copying back from offline/old columns)
  /// to preserve primary keys and sets the state to [ROW_STATE_DELETED].
  Future<int> delete({required String pTableName, FilterCondition? pFilter}) {
    var where = _getWhere(pFilter);
    var offlineTableName = formatOfflineTableName(pTableName);

    return db.transaction((txn) async {
      String? state = await _getState(offlineTableName, where: where, txn: txn);
      if (state != null) {
        if (state == ROW_STATE_INSERTED) {
          // Delete row and return
          return txn.delete(offlineTableName, where: where?[0], whereArgs: where?[1]);
        } else if (state == ROW_STATE_UPDATED) {
          // Reset column to preserve primary key columns and then set Deleted
          List<String> tableColumns = await _getTableColumns(pTableName, txn: txn);

          Map<String, dynamic> updateColumns = {};
          // Constructs "age = $OLD$_age"
          tableColumns.forEach((column) => updateColumns['"$column"'] = '"${formatOfflineColumnName(column)}"');

          await _updateOfflineColumns(
            txn,
            offlineTableName,
            updateColumns,
            where?[0],
            where?[1],
          );
        }
      }
      // Set state to Deleted (D)
      return txn.update(offlineTableName, {'"$STATE_COLUMN"': ROW_STATE_DELETED},
          where: where?[0], whereArgs: where?[1]);
    });
  }

  /// Builds a where clause using [pFilter] which excludes all "deleted" columns.
  ///
  /// Returns either a list in the format `{String, List}` or just `{String, null}`.
  List<dynamic>? _getWhere(FilterCondition? pFilter) {
    String where = '"$STATE_COLUMN" IS NULL OR "$STATE_COLUMN" != \'$ROW_STATE_DELETED\'';
    if (pFilter != null) {
      String? filterWhere = _buildWhereClause(pFilter);
      where = '($filterWhere) AND ($where)';
      var whereArgs = pFilter.getValues().map((e) {
        if (e is String) {
          return e.replaceAll("*", "%").replaceAll("?", "_");
        }
        return e;
      }).toList();
      return [where, whereArgs];
    }
    return [where, null];
  }

  /// Transforms [filter] to a valid SQL where clause.
  ///
  /// Wraps the returned statement in parentheses.
  /// Returns `null` if [filter] contains no properties to build a where clause.
  String? _buildWhereClause(FilterCondition filter) {
    String? where;

    // The main where of the condition, if applicable.
    String? superWhere;
    if (filter.columnName != null) {
      superWhere = _getWhereCondition(filter);
    }

    if (superWhere != null || filter.conditions.isNotEmpty) {
      where = [
        if (superWhere != null) superWhere,
        ...filter.conditions.map((e) => _buildWhereClause(e)).nonNulls,
      ].join(" ${filter.operatorType.name} ");
      where = "($where)";
    }
    return where;
  }

  /// Transforms a [filter] to a valid SQL condition.
  String _getWhereCondition(FilterCondition filter) {
    if (filter.value != null) {
      String operator;
      switch (filter.compareType) {
        case CompareType.Like:
        case CompareType.LikeIgnoreCase:
          operator = "LIKE";
          break;
        case CompareType.Less:
          operator = "<";
          break;
        case CompareType.LessEquals:
          operator = "<=";
          break;
        case CompareType.Greater:
          operator = ">";
          break;
        case CompareType.GreaterEquals:
          operator = ">=";
          break;
        //case CompareType.Equals:
        default:
          operator = "=";
      }

      String clause;
      if (filter.compareType.toString().toLowerCase().contains("ignore_case")) {
        clause = "LOWER(${filter.columnName}) $operator LOWER(?)";
      } else {
        clause = "${filter.columnName} $operator ?";
      }
      if (filter.not == true) {
        return "NOT ($clause)";
      } else {
        return clause;
      }
    } else {
      if (filter.not == true) {
        return "${filter.columnName} NOT IS NULL";
      } else {
        return "${filter.columnName} IS NULL";
      }
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // SQL statement processing
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Executes a List of sql statements in a batch operation (single atomic operation).
  Future<List<Object?>> batch({required List<String> pSqlStatements}) {
    return db.transaction((txn) {
      var batch = txn.batch();
      pSqlStatements.forEach((sql) {
        batch.execute(sql);
      });
      return batch.commit();
    });
  }

  /// Executes a list of sql statements, calls [pProgressCallback] after each statement.
  bulk({required Iterable<String> pSqlStatements, VoidCallback? pProgressCallback}) {
    return db.transaction((txn) {
      return Future.forEach(pSqlStatements, (String sql) async {
        await txn.execute(sql);
        if (pProgressCallback != null) {
          pProgressCallback();
        }
      });
    });
  }

  /// Retrieves the state of a single row of [pTableName] using [where].
  Future<String?> _getState(String pTableName, {List<dynamic>? where, Transaction? txn}) {
    return (txn ?? db)
        .query(pTableName, columns: [STATE_COLUMN], where: where?[0], whereArgs: where?[1])
        .then((value) => value.firstOrNull?[STATE_COLUMN] as String?);
  }

  /// Retrieves all column names of [pTableName] via `PRAGMA_TABLE_INFO`.
  Future<List<String>> _getTableColumns(String pTableName, {Transaction? txn}) {
    return (txn ?? db).rawQuery(
      "SELECT NAME FROM PRAGMA_TABLE_INFO('$pTableName') WHERE NAME NOT LIKE ? AND NAME NOT LIKE ?;",
      [
        "$COLUMN_PREFIX%",
        STATE_COLUMN,
      ],
    ).then((value) => value.map((e) => e['name'] as String).toList(growable: false));
  }
}
