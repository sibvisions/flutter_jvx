import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class DownloadHelper {
  static String getLocalFilePath({
      required String appName,
      required String appVersion,
      required bool translation,
      required String baseDir
  }) {

    if (translation) {
      return '$baseDir/translation/$appName/$appVersion';
    } else {
      return '$baseDir/images/$appName/$appVersion';
    }
  }

  static Future<String> getBaseDir() async {
    return (await getApplicationDocumentsDirectory()).path;
  }

  static Future<void> deleteOutdatedData({bool translation = true, required String baseUrl}) async {
    String trimmedBaseUrl = baseUrl.split('/')[2];

    Directory directory;

    String baseDir = await getBaseDir();

    String identifier;

    if (translation) {
      identifier = 'translation';
    } else {
      identifier = 'images';
    }

    directory = Directory('$baseDir/$identifier/');

    if (directory.existsSync()) {
      List<FileSystemEntity> fileSystemEntities = directory.listSync();

      for (final entity in fileSystemEntities) {
        if (entity.path != '$baseDir/$identifier/$trimmedBaseUrl') {
          Directory baseUrlDir = Directory(entity.path);

          baseUrlDir.deleteSync(recursive: true);
        }
      }
    }
  }

  static Future<bool> isDownloadNeded(String dir) async {
    if (kIsWeb) return true;

    Directory directory = Directory(dir);

    if (directory.existsSync()) {
      return false;
    }

    return true;
  }
}
