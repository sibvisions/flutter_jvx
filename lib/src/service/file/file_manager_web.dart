import 'dart:collection';
import 'dart:io';

import '../config/i_config_service.dart';
import 'fake_file.dart';
import 'file_manager.dart';

/// File manger for web
class FileManagerWeb extends IFileManager {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Contains all files, the file path being the key
  final HashMap<String, File> _files = HashMap();

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
    return Future.value(doesExist);
  }

  @override
  Future<File?> getFile({required String pPath}) {
    File? file = _files[_getSavePath(pPath: pPath)];
    return Future.value(file);
  }

  @override
  Future<File> saveFile({required List<int> pContent, required String pPath}) {
    File file = FakeFile(pPath: _getSavePath(pPath: pPath));
    file.writeAsBytes(pContent);
    _files[_getSavePath(pPath: pPath)] = file;
    return Future.value(file);
  }

  @override
  File? getFileSync({required String pPath}) {
    var a = _files[_getSavePath(pPath: pPath)];
    return a;
  }

  @override
  Future<File?> getIndependentFile({required String pPath}) {
    return Future.value(_files[_preparePath(pPath: pPath)]);
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
    return Future.value(file);
  }

  @override
  Directory? getDirectory({required String pPath}) {
    return null;
  }

  @override
  List<File> getTranslationFiles() {
    List<File> listFiles = [];

    _files.forEach((key, value) {
      if (key.contains("/${IFileManager.LANGUAGES_PATH}/")) {
        listFiles.add(value);
      }
    });

    return listFiles;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Checks of version & name are set will return "/appName/appVersion"
  String _getSavePath({required String pPath}) {
    String? appName = IConfigService().getAppName();
    String? version = IConfigService().getVersion();
    if (appName == null || version == null) {
      throw Exception("App Version/Name was not set while trying to save/read files!");
    }
    return "/$appName/_$version${_preparePath(pPath: pPath)}";
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
