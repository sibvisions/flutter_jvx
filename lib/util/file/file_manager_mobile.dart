import 'dart:io';

import 'package:flutter_client/util/file/file_manager.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileMangerMobile implements IFileManager {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Directory used to store all files internally (.path)
  final Directory directory;

  /// App name under which all files are stored internally
  String? _appName;

  /// App version under which all files are stored internally
  String? _appVersion;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static Future<FileMangerMobile> create() async {
    Directory directory = await getApplicationDocumentsDirectory();

    return FileMangerMobile(directory: directory);
  }

  FileMangerMobile({
    required this.directory,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<bool> doesFileExist({required String pPath}) async {
    bool exists = false;

    exists = await Directory(_getSavePath(pPath: pPath)).exists();

    if (exists) return exists;

    exists = await File(_getSavePath(pPath: pPath)).exists();

    if (exists) return exists;

    return false;
  }

  @override
  Future<File?> getFile({required String pPath}) async {
    File file = File(_getSavePath(pPath: pPath));
    bool doesExist = await file.exists();

    if (doesExist) {
      return file;
    }
    return null;
  }

  @override
  void deleteFile({required String pPath}) {
    File file = File(_getSavePath(pPath: pPath));
    file.delete();
  }

  @override
  Future<File> saveFile({required List<int> pContent, required String pPath}) async {
    File file = File(_getSavePath(pPath: pPath));
    File created = await file.create(recursive: true);
    return created.writeAsBytes(pContent);
  }

  @override
  File? getFileSync({required String pPath}) {
    File file = File(_getSavePath(pPath: pPath));
    bool doesExist = file.existsSync();

    if (doesExist) {
      return file;
    }
    return null;
  }

  @override
  Future<File?> getIndependentFile({required String pPath}) async {
    File file = File(join(directory.path, pPath));

    if (await file.exists()) {
      return file;
    }
    return null;
  }

  @override
  File? getIndependentFileSync({required String pPath}) {
    File file = File(join(directory.path, pPath));

    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  @override
  Future<File> saveIndependentFile({required List<int> pContent, required String pPath}) async {
    File file = File(join(directory.path, pPath));
    File created = await file.create(recursive: true);
    return created.writeAsBytes(pContent);
  }

  @override
  void setAppName({required String pName}) {
    _appName = pName;
  }

  @override
  void setAppVersion({required String? pVersion}) {
    _appVersion = pVersion;
  }

  @override
  Directory? getDirectory({required String pPath}) {
    return Directory(_getSavePath(pPath: pPath));
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Checks of version & name are set will return "directory/appName/appVersion"
  String _getSavePath({required String pPath}) {
    if (_appVersion == null || _appName == null) {
      throw Exception("App Version/Name was not set while trying to save/read files!");
    }
    return join(directory.path, _appName, _appVersion, pPath);
  }
}
