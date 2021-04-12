import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AppVersion {
  final String commit;
  final String date;
  final String buildName;
  final String buildNumber;

  AppVersion(
      {required this.commit,
      required this.date,
      required this.buildName,
      required this.buildNumber});

  AppVersion.fromJson({required Map<String, dynamic> map})
      : commit = map['commit'],
        date = DateFormat('dd.MM.yyyy')
            .format(DateTime.fromMillisecondsSinceEpoch(map['date'])),
        buildName = map['version'].split('+')[0],
        buildNumber = map['version'].split('+')[1];

  static Future<AppVersion?> loadFile(
      {String path = 'assets/version/app_version.json',
      bool package = false}) async {
    try {
      if (path.trim().isNotEmpty) {
        final String configString = await rootBundle
            .loadString(package ? 'packages/flutterclient/$path' : path);

        final Map<String, dynamic> map = json.decode(configString);

        final AppVersion appVersion = AppVersion.fromJson(map: map);

        return appVersion;
      }
    } catch (e) {
      log('Could not load version');
    }
  }
}
