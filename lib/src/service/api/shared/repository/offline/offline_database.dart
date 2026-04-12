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
import '../../../../../util/jvx_logger.dart';
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
  Future<void> init() async {
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

    if (FlutterUI.logAPI.cl(Lvl.d)) {
      FlutterUI.logAPI.d("Create Table SQL:\n$createTableSQL");
    }
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
          columns: ["TABLE_NAME"],
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
  Future<List<DalMetaData>> getMetaData(String appId, {String? dataProvider, Transaction? txn}) {
    List<String> whereArgs = [appId];
    if (dataProvider != null) {
      whereArgs.add(dataProvider);
    }
    return db
        .query(
          OFFLINE_METADATA_TABLE,
          columns: ["META_DATA"],
          where:
              "APP_ID = (SELECT ID FROM $OFFLINE_APPS_TABLE WHERE APP LIKE ?)${dataProvider != null ? " AND DATA_PROVIDER LIKE ?" : ""}",
          whereArgs: whereArgs,
        )
        .then((result) =>
            result.map((e) => DalMetaData.fromJson(jsonDecode(e["META_DATA"] as String))).toList(growable: false));
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

  /// Builds a SQL command to create an offline table on the basis of [table].
  String _buildCreateTableSQL(DalMetaData table) {
    var sql = StringBuffer('CREATE TABLE "${formatOfflineTableName(table.dataProvider)}" (');

    for (var column in table.columnDefinitions) {
      sql.write(_buildCreateColumnSQL(column.name, column));
      // Offline/Old columns are always nullable.
      sql.write(_buildCreateColumnSQL(formatOfflineColumnName(column.name), column, nullable: true));
    }
    sql.write('"$STATE_COLUMN" TEXT\n');

    sql.write(");");
    return sql.toString();
  }

  /// Builds a SQL command to create a column on the basis of [columnDefinition].
  ///
  /// [nullable] is currently ignored, therefore every column is nullable, could be completely dropped in a future release.
  String _buildCreateColumnSQL(String columnName, ColumnDefinition columnDefinition, {bool? nullable}) {
    var columnDef = StringBuffer('"$columnName" ');
    columnDef.write(ITypes.convertToSQLite(columnDefinition.dataTypeIdentifier, scale: columnDefinition.scale));

    // TODO Check default value

    if (IConfigService().getAppConfig()?.offlineConfig!.checkConstraints ?? true) {
      if (columnDefinition.length != null) {
        columnDef.write(' CHECK(length("$columnName") <= ${columnDefinition.length})');
      }

      if (columnDefinition.precision != null) {
        columnDef.write(' CHECK("$columnName" = ROUND("$columnName", ${columnDefinition.precision}))');
      }

      if (!(columnDefinition.signed ?? true)) {
        columnDef.write(' CHECK("$columnName") >= 0)');
      }
    }

    columnDef.write(",\n");
    return columnDef.toString();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Table management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Whether a table named [tableName] exists.
  ///
  /// The table name is escaped using [formatOfflineTableName].
  Future<bool> tableExists(String tableName, {Transaction? txn}) {
    return _tableExists(formatOfflineTableName(tableName), txn: txn);
  }

  /// Whether a table named [tableName] exists.
  Future<bool> _tableExists(String tableName, {Transaction? txn}) {
    String sql = 'SELECT COUNT(*) AS COUNT FROM sqlite_master WHERE TYPE = \'table\' AND NAME = ?;';
    return db.rawQuery(sql, [tableName])
        // Check if returned count in select is 1
        .then((results) => results[0]["COUNT"] as int > 0);
  }

  /// Drops a table named [tableName], if it exists.
  ///
  /// The table name is escaped using [formatOfflineTableName].
  Future<void> dropTable(String tableName, {Transaction? txn}) {
    return _dropTable(formatOfflineTableName(tableName), txn: txn);
  }

  /// Drops a table named [tableName], if it exists.
  Future<void> _dropTable(String tableName, {Transaction? txn}) {
    return (txn ?? db).execute('DROP TABLE IF EXISTS "$tableName";');
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Row Management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Retrieves all rows from this [dataProvider] where the [STATE_COLUMN] is not null.
  ///
  /// Returns an empty map if the table doesn't exist.
  Future<Map<String, List<Map<String, Object?>>>> getChangedRows(String dataProvider, {Transaction? txn}) async {
    if (await tableExists(dataProvider, txn: txn)) {
      return (txn ?? db)
          .query(formatOfflineTableName(dataProvider), where: '"$STATE_COLUMN" IS NOT NULL')
          .then((value) => groupBy(value, (p0) => p0[STATE_COLUMN] as String));
    } else {
      return {};
    }
  }

  /// Resets all state columns for [dataProvider]. (Sets all [STATE_COLUMN]s back to `null`)
  ///
  /// * If [resetRow] is empty, returns `0` and does nothing.
  /// * If row in [resetRow] contains no columns, it is skipped.
  /// * Otherwise the columns in [resetRow] are used to create a where clause.
  Future<int> resetState(String dataProvider, Map<String, Object?> resetRow, {Transaction? txn}) {
    String where = "1 = 0";

    if (resetRow.isNotEmpty) {
      where += " OR (";
      List<String> columns = [];
      for (var column in resetRow.entries) {
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
      formatOfflineTableName(dataProvider),
      {'"$STATE_COLUMN"': null},
      where: where,
      whereArgs: resetRow.values.whereType<Object>().toList(growable: false),
    );
  }

  /// Checks if at least one valid row (not marked as deleted) exists in [tableName], optionally with [filter] applied.
  Future<bool> rowExists({required String tableName, Map<String, dynamic>? filter, Transaction? txn}) {
    String sql = 'SELECT COUNT(*) AS COUNT FROM "${formatOfflineTableName(tableName)}"';
    if (filter != null) {
      sql += " WHERE${filter.keys.map((key) => '"$key" = ?').join(" AND ")}";
      sql += ' AND "$STATE_COLUMN" != \'$ROW_STATE_DELETED\'';
    }

    return (txn ?? db).rawQuery(sql, [...?filter?.values]).then((results) => results[0]["COUNT"] as int > 0);
  }

  /// Executes a SQL SELECT COUNT query for [tableName] and returns the number of valid rows found, optionally with [filter] applied.
  Future<int> getCount({required String tableName, FilterCondition? filter, Transaction? txn}) {
    var where = _getWhere(filter);
    return (txn ?? db)
        .query(formatOfflineTableName(tableName),
            columns: ["COUNT(*) AS COUNT"], where: where?[0], whereArgs: where?[1])
        .then((results) => results[0]["COUNT"] as int);
  }

  /// Executes a SQL SELECT query for [tableName] and returns a list of the valid rows that were found.
  Future<List<Map<String, dynamic>>> select({
    required String tableName,
    List<String>? columns,
    FilterCondition? filter,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    Transaction? txn,
  }) {
    var where = _getWhere(filter);
    return (txn ?? db).query(
      formatOfflineTableName(tableName),
      columns: columns,
      where: where?[0],
      whereArgs: where?[1],
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      // Workaround for https://github.com/tekartik/sqflite/issues/1018
      limit: limit ?? (offset != null ? -1 : null),
      offset: offset,
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // CUD Operations
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Executes a INSERT query for [tableName], sets the state to [ROW_STATE_INSERTED] and returns the last inserted row ID.
  Future<int> insert({required String tableName, required Map<String, dynamic> insert, Transaction? txn}) {
    insert['"$STATE_COLUMN"'] = ROW_STATE_INSERTED;
    return rawInsert(tableName: tableName, insert: insert, txn: txn);
  }

  /// Executes a SQL INSERT query for [tableName] and returns the last inserted row ID.
  Future<int> rawInsert({required String tableName, required Map<String, dynamic> insert, Transaction? txn}) {
    return (txn ?? db).insert(formatOfflineTableName(tableName), insert);
  }

  /// Executes a SQL UPDATE query for [tableName] and returns the number of changes made.
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
  /// [update]: `{age = 10}`
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
    required String tableName,
    required Map<String, dynamic> update,
    FilterCondition? filter,
  }) {
    var where = _getWhere(filter);
    var offlineTableName = formatOfflineTableName(tableName);

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
      return txn.update(offlineTableName, update, where: where?[0], whereArgs: where?[1]);
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

  /// Executes a SQL DELETE query for [tableName] and returns the number of changes made.
  ///
  /// It first checks if the [STATE_COLUMN] is:
  /// * [ROW_STATE_INSERTED], which then simply deletes the row.
  /// * [ROW_STATE_UPDATED], which rolls back all changes (copying back from offline/old columns)
  /// to preserve primary keys and sets the state to [ROW_STATE_DELETED].
  Future<int> delete({required String tableName, FilterCondition? filter}) {
    var where = _getWhere(filter);
    var offlineTableName = formatOfflineTableName(tableName);

    return db.transaction((txn) async {
      String? state = await _getState(offlineTableName, where: where, txn: txn);
      if (state != null) {
        if (state == ROW_STATE_INSERTED) {
          // Delete row and return
          return txn.delete(offlineTableName, where: where?[0], whereArgs: where?[1]);
        } else if (state == ROW_STATE_UPDATED) {
          // Reset column to preserve primary key columns and then set Deleted
          List<String> tableColumns = await _getTableColumns(tableName, txn: txn);

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

  /// Builds a where clause using [filter] which excludes all "deleted" columns.
  ///
  /// Returns either a list in the format `{String, List}` or just `{String, null}`.
  List<dynamic>? _getWhere(FilterCondition? filter) {
    String where = '"$STATE_COLUMN" IS NULL OR "$STATE_COLUMN" != \'$ROW_STATE_DELETED\'';
    if (filter != null) {
      String? filterWhere = _buildWhereClause(filter);
      where = '($filterWhere) AND ($where)';
      var whereArgs = filter.getValues().map((e) {
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
  Future<List<Object?>> batch({required List<String> sqlStatements}) {
    return db.transaction((txn) {
      var batch = txn.batch();
      sqlStatements.forEach((sql) {
        batch.execute(sql);
      });
      return batch.commit();
    });
  }

  /// Executes a list of sql statements, calls [progressCallback] after each statement.
  Future<dynamic> bulk({required Iterable<String> sqlStatements, VoidCallback? progressCallback}) {
    return db.transaction((txn) {
      return Future.forEach(sqlStatements, (String sql) async {
        await txn.execute(sql);
        if (progressCallback != null) {
          progressCallback();
        }
      });
    });
  }

  /// Retrieves the state of a single row of [tableName] using [where].
  Future<String?> _getState(String tableName, {List<dynamic>? where, Transaction? txn}) {
    return (txn ?? db)
        .query(tableName, columns: [STATE_COLUMN], where: where?[0], whereArgs: where?[1])
        .then((value) => value.firstOrNull?[STATE_COLUMN] as String?);
  }

  /// Retrieves all column names of [tableName] via `PRAGMA_TABLE_INFO`.
  Future<List<String>> _getTableColumns(String tableName, {Transaction? txn}) {
    return (txn ?? db).rawQuery(
      "SELECT NAME FROM PRAGMA_TABLE_INFO('$tableName') WHERE NAME NOT LIKE ? AND NAME NOT LIKE ?;",
      [
        "$COLUMN_PREFIX%",
        STATE_COLUMN,
      ],
    ).then((value) => value.map((e) => e["name"] as String).toList(growable: false));
  }
}
