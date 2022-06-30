import 'package:flutter/cupertino.dart';
import 'package:flutter_client/src/service/api/shared/repository/offline/offline_filter.dart';
import 'package:sqflite/sqflite.dart';

class OfflineDatabase {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Instance of sql database
  final Database database;

  int rowsToBeImported = 0;

  int rowsImported = 0;

  /// The last filter that was used to fetch
  OfflineFilter? _lastFetchFilter;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OfflineDatabase({
    required this.database,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Table management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Create a Table if it didn't exist before
  /// [pColumnString] needs to look like "id INTEGER PRIMARY KEY"
  Future<void> createTable({required String pTableName, required String pColumnString}) async {
    String sql = "CREATE TABLE if not exists [$pTableName] ($pColumnString);";
    await database.transaction((txn) async {
      await txn.execute(sql);
    });
  }

  /// Will return true if table with [pTableName] exists
  Future<bool> tableExists({required String pTableName}) async {
    String sql = "SELECT COUNT(*) FROM sqlite_master WHERE TYPE = table AND NAME = $pTableName;";
    bool exists = false;
    await database.transaction((txn) async {
      var results = await txn.rawQuery(sql);

      // Check if returned count in select is 1
      if (results[0]['COUNT(*)']! as int > 0) {
        exists = true;
      }
    });

    return exists;
  }

  /// Drops table with name [pTableName]
  Future<void> dropTable({required String pTableName}) async {
    String sql = "DROP TABLE [$pTableName];";
    await database.transaction((txn) async {
      await database.execute(sql);
    });
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Row Management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Checks if any row exits in [pTableName], if [pWhere] is null
  /// if [pWhere] is not null, will check if any row exists in [pTableName] with [pWhere] applied.
  /// Will return true if at least one row is returned.
  Future<bool> rowExists({required String pTableName, String? pWhere}) async {
    // Add where statement if it exists
    String sql = "SELECT * FROM [$pTableName]";
    if (pWhere != null) {
      sql = "$sql WHERE $pWhere";
    }

    // Return true if more than one row is returned
    List<Map<String, dynamic>> result = [];
    await database.transaction((txn) async {
      result = await txn.rawQuery(sql);
    });
    return result.isNotEmpty;
  }

  /// Returns rows of [pTableName] with supplied conditions ([pWhere], [pOrderBy], [pLimit])
  Future<List<Map<String, dynamic>>> selectRows({required String pTableName, String? pWhere, String? pOrderBy, String? pLimit}) async {
    // Build sql statement
    String sql = "SELECT * FROM [$pTableName]";
    if (pWhere != null) {
      sql = "$sql WHERE $pWhere ";
    }
    if (pOrderBy != null) {
      sql = "$sql ORDER BY $pOrderBy ";
    }
    if (pLimit != null) {
      sql = "$sql LIMIT $pLimit ";
    }

    List<Map<String, dynamic>> result = [];
    await database.transaction((txn) async {
      result = await txn.rawQuery(sql);
    });
    return result;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // CUD Operations
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Inserts Row at the end of [pTableName]
  /// Returns index of inserted row
  Future<int> insert({required String pTableName, required String pColumnString, required String pValueString}) async {
    String sql = "INSERT INTO [$pTableName] ($pColumnString) VALUES ($pValueString)";

    int insertedIndex = -1;
    await database.transaction((txn) async {
      await txn.execute(sql);
      var result = await txn.rawQuery("SELECT COUNT(*) FROM [$pTableName]");
      insertedIndex = result[0]['COUNT(*)']! as int;
    });
    return insertedIndex;
  }

  /// Execute an "UPDATE" statement
  /// Where will only apply if not null
  /// Will always return true - legacy reasons
  Future<bool> update({required String pTableName, required String pSetString, String? pWhere}) async {
    // Build sql statement string
    String sql = "UPDATE [$pTableName] SET [$pSetString]";
    if (pWhere != null) {
      sql = "$sql $pWhere";
    }

    await database.transaction((txn) async {
      await txn.execute(sql);
    });

    return true;
  }

  /// Execute an "DELETE FROM" statement
  /// Where will only apply if not null
  /// Will always return true - legacy reasons
  Future<bool> delete({required String pTableName, required String pWhere}) async {
    String sql = "DELETE FROM [$pTableName] WHERE $pWhere";
    await database.transaction((txn) async {
      await txn.execute(sql);
    });
    return true;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // SQL statement processing
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Executes a List of sql statements, will call [pProgressCallback] after each statement
  /// Will complete return future when all statements have been processed
  Future<void> bulk({required List<String> pSqlStatements, VoidCallback? pProgressCallback}) async {
    await database.transaction((txn) async {
      await Future.forEach(pSqlStatements, (String sql) async {
        await txn.execute(sql);
        if (pProgressCallback != null) {
          pProgressCallback();
        }
      });
    });
  }

  /// Executes a List of sql statements in a bulk statement (single atomic operation)
  /// Will complete return future when all statements have been processed
  Future<void> batch({required List<String> pSqlStatements}) async {
    database.transaction((txn) async {
      var batch = txn.batch();
      pSqlStatements.forEach((sql) {
        batch.execute(sql);
      });

      await batch.commit(noResult: true);
    });
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Offline Database implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
}
