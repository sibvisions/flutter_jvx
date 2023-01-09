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

import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../config/config_controller.dart';
import 'file_manager.dart';

class FileManagerMobile extends IFileManager {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Directory used to store all files internally (.path)
  final Directory directory;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static Future<FileManagerMobile> create() async {
    Directory directory = await getApplicationDocumentsDirectory();

    return FileManagerMobile(directory: directory);
  }

  FileManagerMobile({
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
    File file = File(join(directory.path, _fixPath(pPath)));

    if (await file.exists()) {
      return file;
    }
    return null;
  }

  @override
  File? getIndependentFileSync({required String pPath}) {
    File file = File(join(directory.path, _fixPath(pPath)));

    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  @override
  Future<File> saveIndependentFile({required List<int> pContent, required String pPath}) async {
    File file = File(join(directory.path, _fixPath(pPath)));
    File created = await file.create(recursive: true);
    return created.writeAsBytes(pContent);
  }

  @override
  Directory? getDirectory({required String pPath}) {
    return Directory(_getSavePath(pPath: pPath));
  }

  @override
  List<File> getTranslationFiles() {
    List<File> listFiles = [];

    Directory? dir = getDirectory(pPath: "${IFileManager.LANGUAGES_PATH}/");

    if (dir != null && dir.existsSync()) {
      listFiles.addAll(dir.listSync().whereType<File>().toList());
    }

    return listFiles;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Checks of version & name are set will return "directory/appName/appVersion"
  String _getSavePath({required String pPath}) {
    String? appName = ConfigController().appName.value;
    String? version = ConfigController().version.value;
    if (appName == null || version == null) {
      throw Exception("App Version/Name was not set while trying to save/read files!");
    }
    return join(directory.path, appName, version, _fixPath(pPath));
  }

  /// Removes leading slashes
  /// "example.txt" -> "example.txt"
  /// "/example.txt" -> "example.txt"
  String _fixPath(String pPath) {
    while (pPath.startsWith("/")) {
      pPath = pPath.substring(1);
    }
    return pPath;
  }
}
