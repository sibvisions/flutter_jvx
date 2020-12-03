import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/app/app_state.dart';
import 'get_local_file_path.dart';

Future<bool> shouldDownload(AppState appState) async {
  String _baseDirectory;

  if (kIsWeb) {
    return true;
  }

  if (Platform.isIOS) {
    _baseDirectory = (await getApplicationSupportDirectory()).path;
  } else {
    _baseDirectory = (await getApplicationDocumentsDirectory()).path;
  }

  Directory dir = Directory(getLocalFilePath(
      appState.baseUrl, _baseDirectory, appState.appName, appState.appVersion));

  if (dir.existsSync()) {
    return false;
  }

  return true;
}
