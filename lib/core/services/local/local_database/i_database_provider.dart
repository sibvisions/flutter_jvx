import 'package:sqflite/sqflite.dart';

abstract class IDatabaseProvider {
  Database db;

  Future<void> openCreateDatabase(String path);
  Future<void> closeDatabase();
}
