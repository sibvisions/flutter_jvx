import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

String getLocalFilePath(
    {required String baseUrl,
    required String appName,
    required String appVersion,
    required bool translation,
    required String baseDir}) {
  String trimmedBaseUrl = baseUrl.split('/')[2];

  if (translation)
    return '$baseDir/translation/$trimmedBaseUrl/$appName/$appVersion';
  else
    return '$baseDir/images/$trimmedBaseUrl/$appName/$appVersion';
}

Future<String> getBaseDir() async {
  return (await getApplicationDocumentsDirectory()).path;
}

Future<void> deleteOutdatedData(
    {bool translation = true, required String baseUrl}) async {
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

Future<bool> isDownloadNeded(String dir) async {
  if (kIsWeb) return true;

  Directory directory = Directory(dir);

  if (directory.existsSync()) {
    return false;
  }

  return true;
}
