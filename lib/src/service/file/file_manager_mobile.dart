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
  String getAppSpecificPath(String path, {String? appName, String? version}) {
    String? effectiveAppName = appName ?? ConfigController().appName.value;
    String? effectiveVersion = version ?? ConfigController().version.value;
    if (effectiveAppName == null || effectiveVersion == null) {
      throw Exception("App Version/Name was not set while trying to build app specific path");
    }
    return join(effectiveAppName, effectiveVersion, _preparePath(path));
  }

  @override
  Future<bool> doesFileExist(String pPath) async {
    bool exists = false;

    exists = await Directory(_getSavePath(pPath)).exists();

    if (exists) return exists;

    exists = await File(_getSavePath(pPath)).exists();

    if (exists) return exists;

    return false;
  }

  @override
  Future<File?> getFile(String pPath) async {
    File file = File(_getSavePath(pPath));
    bool doesExist = await file.exists();

    if (doesExist) {
      return file;
    }
    return null;
  }

  @override
  void deleteFile(String pPath) {
    File file = File(_getSavePath(pPath));
    file.delete();
  }

  @override
  Future<File> saveFile(String pPath, {required List<int> pContent}) async {
    File file = File(_getSavePath(pPath));
    File created = await file.create(recursive: true);
    return created.writeAsBytes(pContent);
  }

  @override
  File? getFileSync(String pPath) {
    File file = File(_getSavePath(pPath));
    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  @override
  Directory? getDirectory(String pPath) {
    return Directory(_getSavePath(pPath));
  }

  @override
  Future<void> deleteIndependentDirectory(List<String> pPath, {bool recursive = false}) {
    var dir = Directory(joinAll([directory.path, ...pPath]));
    if (dir.existsSync()) {
      return dir.delete(recursive: recursive);
    } else {
      return Future.value();
    }
  }

  @override
  Future<void> removePreviousAppVersions(String appName, String currentVersion) async {
    Directory appDirectory = Directory(join(directory.path, appName));
    if (appDirectory.existsSync()) {
      await for (var entity in appDirectory.list()) {
        if (basename(entity.path) != currentVersion) {
          await entity.delete(recursive: true);
        }
      }
    } else {
      return Future.value();
    }
  }

  @override
  List<File> getTranslationFiles() {
    List<File> listFiles = [];

    Directory dir = Directory(_getSavePath("${IFileManager.LANGUAGES_PATH}/"));

    if (dir.existsSync()) {
      listFiles.addAll(dir.listSync().whereType<File>().toList());
    }

    return listFiles;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String _getSavePath(String path) {
    return join(directory.path, _preparePath(path));
  }

  /// Removes leading slashes.
  ///
  /// Examples:
  /// * "example.txt" -> "example.txt"
  /// * "/example.txt" -> "example.txt"
  String _preparePath(String path) {
    while (path.startsWith("/")) {
      path = path.substring(1);
    }
    return path;
  }
}
