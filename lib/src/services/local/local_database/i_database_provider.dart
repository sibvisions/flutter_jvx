import 'package:sqflite/sqflite.dart';

abstract class IDatabaseProvider {
  Database? db;

  bool get isOpen;

  Future<bool> openCreateDatabase(String path);
  Future<void> closeDatabase();
}
