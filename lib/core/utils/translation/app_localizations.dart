import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../injection_container.dart';
import '../../models/app/app_state.dart';

class AppLocalizations {
  final Locale locale;
  static Map<String, dynamic> _localizedValues = <String, dynamic>{};

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Future<AppLocalizations> load(Locale locale) async {
    AppState appState = sl<AppState>();

    try {
      if (appState.translation != null &&
          appState.translation.isNotEmpty &&
          appState.translation['translation_${locale.languageCode}.json'] !=
              null) {
        final file = File(
            appState.translation['translation_${locale.languageCode}.json']);

        String contents = await file.readAsString();

        if (contents != null && contents.length > 0) {
          List<dynamic> translationList = json.decode(contents);
          _localizedValues = <String, dynamic>{};

          translationList.forEach((translation) {
            _localizedValues.putIfAbsent(
                translation['text'], () => translation['translation']);
          });
        }
      } else if (appState.translation != null &&
          appState.translation.isNotEmpty &&
          appState.translation['translation.json'] != null) {
        final file = File(appState.translation['translation.json']);

        String contents = await file.readAsString();

        if (contents != null && contents.length > 0) {
          List<dynamic> translationList = json.decode(contents);
          _localizedValues = <String, dynamic>{};

          translationList.forEach((translation) {
            _localizedValues.putIfAbsent(
                translation['text'], () => translation['translation']);
          });
        }
      }
    } catch (e) {
      return AppLocalizations(const Locale('en'));
    }

    return AppLocalizations(locale);
  }

  String text(String key) {
    return _localizedValues[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'de'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
