import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_client/src/model/data/column_definition.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_client/util/constants/i_types.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/api/response/dal_meta_data_response.dart';

/// Table and column names are escaped via double quotes.<br>
/// https://www.sqlite.org/lang_keywords.html
///
/// Has to be closed with [close()]
class OfflineDatabase with ConfigServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const COLUMN_PREFIX = "\$OLD\$_";
  static const STATE_COLUMN = "\$state\$";
  static const ROW_STATE_INSERTED = "I";
  static const ROW_STATE_UPDATED = "U";
  static const ROW_STATE_DELETED = "D";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data definition
  final List<DalMetaDataResponse> dalMetaData;

  /// Instance of sql database
  late Database database;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OfflineDatabase._create({required this.dalMetaData});

  static Future<OfflineDatabase> open({required List<DalMetaDataResponse> dalMetaData}) async {
    var offlineDatabase = OfflineDatabase._create(dalMetaData: dalMetaData);
    await offlineDatabase.init();
    return offlineDatabase;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Init and define Database
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  init() async {
    // Avoid errors caused by flutter upgrade.
    WidgetsFlutterBinding.ensureInitialized();

    // Open the database and store the reference.
    database = await openDatabase(
      // Set the path to the database.
      join(await getDatabasesPath(), 'jvx_offline_data.sqlite'),
      onCreate: (db, version) {
        return dalMetaData.map((table) {
          return _createTable(table);
        }).forEach((createTableSQL) async {
          if (kDebugMode) print("Creating Table: " + createTableSQL);
          // Run the CREATE TABLE statement on the database.
          await db.execute(createTableSQL);
        });
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      //TODO check version (sync with app_version?)
      version: 1,
    );
  }

  close() {
    return database.close();
  }

  ///Constructs the identifier for the offline table.
  String formatOfflineTableName(String tableName) {
    return tableName.replaceAll(RegExp(r"[^\w_]"), "_");
  }

  ///Constructs the identifier for the offline column.
  String formatOfflineColumnName(String columnName) {
    return COLUMN_PREFIX + columnName;
  }

  String _createTable(DalMetaDataResponse pTable) {
    var sql = StringBuffer('CREATE TABLE "${formatOfflineTableName(pTable.dataProvider)}" (');

    for (var column in pTable.columns) {
      sql.write(_createColumn(column.name, column));
      sql.write(_createColumn(formatOfflineColumnName(column.name), column, nullable: true));
    }
    sql.write('"$STATE_COLUMN" TEXT\n');

    if (pTable.primaryKeyColumns.isNotEmpty) {
      sql.write(', PRIMARY KEY ("' + pTable.primaryKeyColumns.join('", "') + '")\n');
    }

    //TODO evaluate STRICT
    sql.write(") STRICT;");
    return sql.toString();
  }

  String _createColumn(String pColumnName, ColumnDefinition pColumn, {bool? nullable}) {
    var columnDef = StringBuffer('"$pColumnName" ');
    columnDef.write(Types.convertToSQLite(pColumn.dataTypeIdentifier));

    //Check overridden value first, then column spec
    if (!(nullable ?? pColumn.nullable)) {
      columnDef.write(" NOT NULL");
    }

    //TODO Check default value

    if (pColumn.length != null) {
      columnDef.write(' CHECK(length("$pColumnName") <= ${pColumn.length})');
    }

    if (pColumn.precision != null) {
      columnDef.write(' CHECK("$pColumnName" = ROUND("$pColumnName", ${pColumn.precision}))');
    }

    if (!(pColumn.signed ?? true)) {
      columnDef.write(' CHECK("$pColumnName") >= 0)');
    }

    columnDef.write(",\n");
    return columnDef.toString();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Table management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns true if table with [pTableName] exists
  tableExists(String pTableName) {
    String sql = 'SELECT COUNT(*) AS COUNT FROM sqlite_schema WHERE TYPE = table AND NAME = "?";';
    return database.rawQuery(sql, [formatOfflineTableName(pTableName)])
        // Check if returned count in select is 1
        .then((results) => results[0]['COUNT'] as int > 0);
  }

  /// Drops table with name [pTableName]
  dropTable(String pTableName) {
    return database.execute('DROP TABLE "$pTableName";');
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Row Management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Checks if any row exists in [pTableName]
  /// if [pWhere] is not null, check with [pWhere] applied.
  /// Returns true if at least one row is returned.
  rowExists({required String pTableName, Map<String, dynamic>? pFilter}) {
    String sql = 'SELECT COUNT(*) AS COUNT FROM "${formatOfflineTableName(pTableName)}"';
    if (pFilter != null) {
      sql += _buildWhere(pFilter.keys);
    }

    return database.rawQuery(sql, [...?pFilter?.values])
        // Check returned count
        .then((results) => results[0]['COUNT'] as int > 0);
  }

  /// Executes a SQL SELECT query and returns a list of the rows that were found.
  select({required String pTableName, Map<String, dynamic>? pFilter, String? pOrderBy, int? pLimit}) {
    var where = _getWhere(pFilter);
    return database.query(formatOfflineTableName(pTableName), where: where?[0], whereArgs: where?[1], orderBy: pOrderBy, limit: pLimit);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // CUD Operations
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Executes a SQL INSERT query and returns the last inserted row ID.
  insert({required String pTableName, required Map<String, dynamic> pInsert}) {
    pInsert[STATE_COLUMN] = ROW_STATE_INSERTED;
    return database.insert(formatOfflineTableName(pTableName), pInsert);
  }

  /// Executes a SQL UPDATE query and returns the number of changes made.
  update({required String pTableName, required Map<String, dynamic> pUpdate, Map<String, dynamic>? pFilter}) {
    //TODO test solution
    //Constructs "$OLD$_age = age"
    Map<String, dynamic> updateColumns = {STATE_COLUMN: ROW_STATE_UPDATED};
    pUpdate.keys.forEach((key) => updateColumns[formatOfflineColumnName(key)] = key);
    updateColumns.addAll(pUpdate);

    //age = 5
    //UPDATE AGE = 10
    //$OLD$_age = 5, age = 10
    var where = _getWhere(pFilter);
    return database.update(formatOfflineTableName(pTableName), updateColumns, where: where?[0], whereArgs: where?[1]);
  }

  /// Executes a SQL DELETE query and returns the number of changes made.
  delete({required String pTableName, Map<String, dynamic>? pFilter}) {
    var where = _getWhere(pFilter);
    //Just set state to Deleted (D)
    return database.transaction((txn) {
      return txn.update(formatOfflineTableName(pTableName), {STATE_COLUMN: ROW_STATE_DELETED}, where: where?[0], whereArgs: where?[1]);
    });
  }

  List<dynamic>? _getWhere(Map<String, dynamic>? pFilter) {
    if (pFilter != null) {
      var where = _buildWhere(pFilter.keys);
      var whereArgs = pFilter.values.toList(growable: false);
      return [where, whereArgs];
    }
    return null;
  }

  ///Build where string and exclude all "deleted" columns
  String _buildWhere(Iterable<String> pFilter) {
    return " WHERE " + pFilter.map((key) => '"$key" = ?').join("AND ") + " AND $STATE_COLUMN != '$ROW_STATE_DELETED'";
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // SQL statement processing
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Executes a List of sql statements in a batch operation (single atomic operation)
  batch({required List<String> pSqlStatements}) {
    return database.transaction((txn) {
      var batch = txn.batch();
      pSqlStatements.forEach((sql) {
        batch.execute(sql);
      });
      return batch.commit();
    });
  }

  /// Executes a list of sql statements, calls [pProgressCallback] after each statement
  bulk({required Iterable<String> pSqlStatements, VoidCallback? pProgressCallback}) {
    return database.transaction((txn) {
      return Future.forEach(pSqlStatements, (String sql) async {
        await txn.execute(sql);
        if (pProgressCallback != null) {
          pProgressCallback();
        }
      });
    });
  }
}
