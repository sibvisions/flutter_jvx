import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../mixin/config_service_mixin.dart';
import 'file_manager_mobile.dart';
import 'file_manager_web.dart';

/// File manager used to manage all file interaction (different implementations for web and mobile)
abstract class IFileManager with ConfigServiceGetterMixin {
  static const String IMAGES_PATH = "images";

  ///Constructs a FileManager depending on the platform
  static Future<IFileManager> getFileManager() async {
    return kIsWeb ? FileManagerWeb() : await FileMangerMobile.create();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Check if a file/directory with the given path exists
  Future<bool> doesFileExist({required String pPath});

  /// Get File from provided path, returns null if file was not found
  Future<File?> getFile({required String pPath});

  /// Get a file that does not depend an app version or app name
  Future<File?> getIndependentFile({required String pPath});

  /// Get File from provided path, returns null if file was not found
  File? getFileSync({required String pPath});

  /// Get a file that does not depend an app version or app name
  File? getIndependentFileSync({required String pPath});

  /// Delete file/directory with provided path
  void deleteFile({required String pPath});

  /// Save File in provided path
  Future<File> saveFile({required List<int> pContent, required String pPath});

  /// Save a file that does not depend on a version or appName
  Future<File> saveIndependentFile({required List<int> pContent, required String pPath});

  /// Returns directory, will always return null if in web
  Directory? getDirectory({required String pPath});
}
