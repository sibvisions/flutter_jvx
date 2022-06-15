import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_client/util/file/fake_file.dart';
import 'package:flutter_client/util/file/file_manager.dart';

/// File manger for web
class FileManagerWeb implements IFileManager {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Contains all files, the file path being the key
  final HashMap<String, File> _files = HashMap();

  /// App name under which all files are stored internally
  String? _appName;

  /// App version under which all files are stored internally
  String? _appVersion;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void deleteFile({required String pPath}) {
    _files.removeWhere((key, value) => key == pPath);
  }

  @override
  Future<bool> doesFileExist({required String pPath}) {
    bool doesExist = _files.containsKey(_getSavePath(pPath: pPath));
    return SynchronousFuture(doesExist);
  }

  @override
  Future<File?> getFile({required String pPath}) {
    File? file = _files[_getSavePath(pPath: pPath)];
    return SynchronousFuture(file);
  }

  @override
  Future<File> saveFile({required List<int> pContent, required String pPath}) {
    File file = FakeFile(pPath: _getSavePath(pPath: pPath));
    file.writeAsBytes(pContent);
    _files[_getSavePath(pPath: pPath)] = file;
    return SynchronousFuture(file);
  }

  @override
  File? getFileSync({required String pPath}) {
    var a = _files[_getSavePath(pPath: pPath)];
    return a;
  }

  @override
  Future<File?> getIndependentFile({required String pPath}) {
    return SynchronousFuture(_files[_preparePath(pPath: pPath)]);
  }

  @override
  File? getIndependentFileSync({required String pPath}) {
    return _files[_preparePath(pPath: pPath)];
  }

  @override
  Future<File> saveIndependentFile({required List<int> pContent, required String pPath}) {
    File file = FakeFile(pPath: _preparePath(pPath: pPath));
    file.writeAsBytes(pContent);
    _files[file.path] = file;
    return SynchronousFuture(file);
  }

  @override
  void setAppName({required String pName}) {
    _appName = pName;
  }

  @override
  void setAppVersion({required String pVersion}) {
    _appVersion = pVersion;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Checks of version & name are set will return "/appName/appVersion"
  String _getSavePath({required String pPath}) {
    if (_appVersion == null || _appName == null) {
      throw Exception("App Version/Name was not set while trying to save/read files!");
    }
    return "/$_appName/_$_appVersion${_preparePath(pPath: pPath)}";
  }

  /// Will prepare the path to be uniform (always have a leading "/")
  /// "example.txt" -> "/example.txt"
  /// "/example.txt" -> "/example.txt"
  String _preparePath({required String pPath}) {
    if (!pPath.startsWith("/")) {
      pPath = "/$pPath";
    }
    return pPath;
  }
}
