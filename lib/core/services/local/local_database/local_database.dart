import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import 'i_database_provider.dart';

typedef ProgressCallback();

class LocalDatabase implements IDatabaseProvider {
  bool debug = true;
  Database db;
  String path;

  bool get isOpen => db != null;

  Future<bool> openCreateDatabase(String path) async {
    if (this.debug) log('SQLite openCreateDatabase:' + path);
    this.db = await openDatabase(path, version: 1);
    this.path = path;

    return this.db?.isOpen ?? false;
  }

  Future<void> closeDatabase() async {
    if (this.db?.isOpen ?? false) await this.db.close();
  }

  Future<bool> createTable(String tableName, String columnStr) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return false;

    String sql = "CREATE TABLE if not exists [$tableName] ($columnStr);";

    if (this.debug) {
      log('SQLite createTable:' + sql);
    }
    try {
      await this.db.execute(sql);
      return true;
    } catch (ee) {
      rethrow;
    }
  }

  Future<bool> dropTable(String tableName) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return false;

    if (await this.tableExists(tableName)) {
      String sql = "DROP TABLE [$tableName];";
      await this.db.execute(sql);

      if (this.debug) {
        log('SQLite dropTable:' + sql);
      }

      if (!await this.tableExists(tableName)) return false;
    }

    return false;
  }

  Future<bool> cleanTable(String tableName) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return false;

    if (await this.tableExists(tableName)) {
      String sql = "DELETE FROM [$tableName];";
      await this.db.execute(sql);

      if (this.debug) {
        log('SQLite cleanTable:' + sql);
      }

      if (!await this.tableExists(tableName)) return false;
    }

    return false;
  }

  Future<bool> tableExists(String tableName) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return false;

    List<Map<String, dynamic>> result = await this.db.rawQuery(
        "SELECT COUNT(*) FROM sqlite_master WHERE type = ? AND name = ?",
        ['table', tableName]);

    return (result != null &&
        result.length > 0 &&
        result[0] != null &&
        result[0].length > 0 &&
        result[0]['COUNT(*)'] >
            0); // && result[0] is QueryRow && result[0].row[0]>0);
  }

  Future<bool> rowExists(String tableName, [String where]) async {
    if (tableName == null || this.db == null || !this.db.isOpen) {
      return false;
    }

    String sql = "SELECT * FROM [$tableName]";

    if (where != null && where.length > 0) {
      sql = "$sql WHERE $where";
    }

    if (this.debug) {
      log('SQLite rowExists:' + sql);
    }

    List<Map<String, dynamic>> result = await this.db.rawQuery(sql);
    return result.length > 0;
  }

  Future<int> rowCount(String tableName) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return 0;

    List<Map<String, dynamic>> result =
        await this.db.rawQuery("SELECT COUNT(*) FROM [$tableName]");

    if (result != null &&
        result.length > 0 &&
        result[0] != null &&
        result[0].length > 0 &&
        result[0].containsKey('COUNT(*)')) {
      return result[0]['COUNT(*)'];
    }

    return 0;
  }

  Future<List<Map<String, dynamic>>> selectRows(String tableName,
      [String where, String orderBy, String limit]) async {
    if (tableName == null || this.db == null || !this.db.isOpen) {
      return null;
    }

    String sql = "SELECT * FROM [$tableName]";

    if (where != null && where.length > 0) {
      sql = "$sql WHERE $where";
    }

    if (orderBy != null && orderBy.length > 0) {
      sql = "$sql ORDER BY $orderBy";
    }

    if (limit != null && limit.length > 0) {
      sql = "$sql LIMIT $limit";
    }

    if (this.debug) {
      log('SQLite selectRows:' + sql);
    }

    return await this.db.rawQuery(sql);
  }

  Future<bool> insert(
      String tableName, String columnString, String valueString) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return false;

    String sql =
        "INSERT INTO [$tableName] ($columnString) VALUES ($valueString)";

    if (this.debug) {
      log('SQLite insert:' + sql);
    }

    await this.db.execute(sql);

    return true;
  }

  Future<void> bulk(List<String> sqlStatements,
      [ProgressCallback callback]) async {
    if (this.db == null || !this.db.isOpen) return;

    await this.db.transaction((txn) async {
      await Future.forEach(sqlStatements, (sql) async {
        await txn.execute(sql);
        if (callback != null) {
          callback();
        }
      });
    });
  }

  Future<void> batch(List<String> sqlStatements) async {
    if (this.db == null || !this.db.isOpen) return;

    await this.db.transaction((txn) async {
      var batch = txn.batch();
      sqlStatements.forEach((sql) {
        batch.execute(sql);
      });

      batch.commit(noResult: true);
    });
  }

  Future<bool> update(String tableName, String setString, String where) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return false;

    if (where != null && where.length > 0) {
      where = " WHERE $where";
    } else {
      where = "";
    }

    String sql = "UPDATE [$tableName] SET $setString$where;";

    if (this.debug) {
      log('SQLite update:' + sql);
    }

    this.db.execute(sql);
    return true;
  }

  Future<bool> delete(String tableName, String where) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return false;

    String sql = "DELETE FROM [$tableName] WHERE $where;";

    if (this.debug) {
      log('SQLite delete:' + sql);
    }

    this.db.execute(sql);

    return true;
  }

  Future<void> setSynchronous(bool onOff) async {
    if (this.db == null || !this.db.isOpen) return;

    String sql = "PRAGMA synchronous = OFF";

    if (onOff) sql = "PRAGMA synchronous = ON";

    if (this.debug) {
      log('SQLite setSynchronous:' + sql);
    }

    this.db.execute(sql);
  }

  Future<void> beginTransaction() async {
    if (this.db == null || !this.db.isOpen) return;

    String sql = "BEGIN TRANSACTION";

    if (this.debug) {
      log('SQLite beginTransaction:' + sql);
    }

    this.db.execute(sql);

    return true;
  }

  Future<void> commitTransaction() async {
    if (this.db == null || !this.db.isOpen) return;

    String sql = "COMMIT";

    if (this.debug) {
      log('SQLite commitTransaction:' + sql);
    }

    this.db.execute(sql);
  }

  Future<void> rollbackTransaction() async {
    if (this.db == null || !this.db.isOpen) return;

    String sql = "ROLLBACK";

    if (this.debug) {
      log('SQLite rollbackTransaction:' + sql);
    }

    this.db.execute(sql);
  }

  Future<void> setCacheSize(int size) async {
    if (this.db == null || !this.db.isOpen) return;

    String sql = "PRAGMA cache_size=${size.toString()}";

    if (this.debug) {
      log('SQLite setCacheSize:' + sql);
    }

    this.db.execute(sql);
  }

  static String escapeStringForSqlLite(String stringToEscape) {
    return stringToEscape.replaceAll("'", "''");
  }
}
