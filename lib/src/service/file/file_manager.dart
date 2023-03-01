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

import 'package:flutter/foundation.dart';

import '../config/config_controller.dart';
import 'file_manager_mobile.dart';
import 'file_manager_web.dart';

/// File manager used to manage all file interaction (different implementations for web and mobile)
///
/// "independent" means this method does not prefix the path with an app name and version.
abstract class IFileManager {
  static const String IMAGES_PATH = "images";
  static const String LANGUAGES_PATH = "languages";

  /// Constructs a FileManager depending on the platform
  static Future<IFileManager> getFileManager() async {
    return kIsWeb ? FileManagerWeb() : await FileManagerMobile.create();
  }

  /// Returns if all requirements are set to successfully access files
  bool isSatisfied() {
    return ConfigController().appName.value != null && ConfigController().version.value != null;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns "appName/appVersion" with platform-aware separators.
  String getAppSpecificPath(String path, {String? appName, String? version});

  /// Check if a file/directory with the given path exists
  Future<bool> doesFileExist(String pPath);

  /// Get File from provided path, returns null if file was not found
  Future<File?> getFile(String pPath);

  /// Get File from provided path, returns null if file was not found
  File? getFileSync(String pPath);

  /// Delete file/directory with provided path
  void deleteFile(String pPath);

  /// Save File in provided path
  Future<File> saveFile(String pPath, {required List<int> pContent});

  /// Returns directory, will always return null if in web
  Directory? getDirectory(String pPath);

  /// Deletes a independent directory.
  Future<void> deleteIndependentDirectory(List<String> pPath, {bool recursive = false});

  /// Removes all previous app versions.
  ///
  /// More specific, removes all [appName] app directories with another version than [currentVersion].
  Future<void> removePreviousAppVersions(String appName, String currentVersion);

  /// Returns directory, will always return null if in web
  List<File> getTranslationFiles();
}
