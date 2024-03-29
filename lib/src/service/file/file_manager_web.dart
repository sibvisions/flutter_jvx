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

import 'dart:collection';
import 'dart:io';

import '../config/i_config_service.dart';
import 'fake_file.dart';
import 'file_manager.dart';

/// File manager for web
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
  String getAppSpecificPath(String path, {String? appId, String? version}) {
    String? effectiveAppId = appId ?? IConfigService().currentApp.value;
    String? effectiveVersion = version ?? IConfigService().version.value;
    if (effectiveAppId == null || effectiveVersion == null) {
      throw Exception("App Version/Name was not set while trying to build app specific path");
    }
    return "/$effectiveAppId/$effectiveVersion${_preparePath(path)}";
  }

  @override
  void deleteFile(String pPath) {
    _files.removeWhere((key, value) => key == _preparePath(pPath));
  }

  @override
  Future<bool> doesFileExist(String pPath) {
    bool doesExist = _files.containsKey(_preparePath(pPath));
    return Future.value(doesExist);
  }

  @override
  Future<File?> getFile(String pPath) {
    File? file = _files[_preparePath(pPath)];
    return Future.value(file);
  }

  @override
  Future<File> saveFile(String pPath, {required List<int> pContent}) {
    File file = FakeFile(_preparePath(pPath));
    file.writeAsBytes(pContent);
    _files[file.path] = file;
    return Future.value(file);
  }

  @override
  File? getFileSync(String pPath) {
    return _files[_preparePath(pPath)];
  }

  @override
  Directory? getDirectory(String pPath) {
    return null;
  }

  @override
  Future<void> renameIndependentDirectory(List<String> pPath, String pNewName) async {
    String path = _preparePath(pPath.join("/"));
    List<String> parentPath = List.of(pPath)
      ..removeLast()
      ..add(pNewName);
    String newPath = _preparePath(parentPath.join("/"));

    Map<String, File> copyMap = Map.of(_files);
    for (MapEntry<String, File> entry in copyMap.entries) {
      if (entry.key.startsWith(path)) {
        String newKey = entry.key.replaceFirst(path, newPath);
        if (entry.key == newKey) continue;
        _files[newKey] = entry.value;
        _files.remove(entry.key);
      }
    }
  }

  @override
  Future<void> deleteIndependentDirectory(List<String> pPath, {bool recursive = false}) async {
    String path = _preparePath(pPath.join("/"));
    _files.removeWhere((key, value) => key.startsWith(path));
  }

  /// Ignores the version as this will only be used before the app is downloaded
  /// and there is no persistence besides this in the web.
  @override
  Future<void> removePreviousAppVersions(String appId, String currentVersion) {
    return deleteIndependentDirectory([appId]);
  }

  @override
  List<File> listTranslationFiles({String? appId, String? version}) {
    List<File> listFiles = [];

    String? effectiveAppId = appId ?? IConfigService().currentApp.value;
    String? effectiveVersion = version ?? IConfigService().version.value;

    if (effectiveAppId == null || effectiveVersion == null) {
      return listFiles;
    }

    String appPath = _preparePath(getAppSpecificPath(
      IFileManager.LANGUAGES_PATH,
      appId: effectiveAppId,
      version: effectiveVersion,
    ));
    appPath += "/";

    _files.forEach((key, value) {
      if (key.contains(appPath)) {
        listFiles.add(value);
      }
    });

    return listFiles;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Prepares the path to be uniform (always have a leading "/").
  ///
  /// Examples:
  /// * "example.txt" -> "/example.txt"
  /// * "/example.txt" -> "/example.txt"
  String _preparePath(String path) {
    if (!path.startsWith("/")) {
      path = "/$path";
    }
    return path;
  }
}
