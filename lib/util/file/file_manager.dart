import 'dart:io';

/// File manager used to manage all file interaction (different implementations for web and mobile)
abstract class IFileManager {
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

  /// Sets the app name under which all files are saved internally
  void setAppName({required String pName});

  /// Sets the app version under which all files are saved internally
  void setAppVersion({required String? pVersion});

  /// Returns directory, will always return null if in web
  Directory? getDirectory({required String pPath});
}
