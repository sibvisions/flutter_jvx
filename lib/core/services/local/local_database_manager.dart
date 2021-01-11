import 'package:sqflite/sqflite.dart';
import 'package:w_common/disposable.dart';

import 'local_database/i_database_provider.dart';
import 'local_database/local_database.dart';
import 'local_database/offline_database.dart';

class LocalDatabaseManager extends Object with Disposable {
  static final LocalDatabaseManager localDatabaseManager =
      LocalDatabaseManager._();

  Map<String, IDatabaseProvider> openDatabases =
      new Map<String, IDatabaseProvider>();

  LocalDatabaseManager._();

  Future<T> getDatabase<T extends IDatabaseProvider>(
      T Function() creator, String path) async {
    if (openDatabases.containsKey(path)) {
      if (openDatabases[path] is T)
        return openDatabases[path];
      else
        return null;
    }

    T provider = creator();
    await provider.openCreateDatabase(path);
    openDatabases[path] = provider;

    return provider;
  }

  Future<Null> onDispose() {
    openDatabases.forEach((key, value) {
      value.closeDatabase();
    });
    openDatabases.clear();

    return null;
  }
}
