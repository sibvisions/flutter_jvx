import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../flutterclient.dart';
import '../../models/state/app_state.dart';

/// Helper class for parsing the translation.
class TranslationHelper {
  static const String textKey = 'text';
  static const String translationKey = 'translation';

  static Map<String, dynamic> loadTranslation(Locale locale) {
    AppState appState = sl<AppState>();

    try {
      if (kIsWeb) {
        return handleWeb(appState, locale);
      } else {
        return handleMobile(appState, locale);
      }
    } on Exception catch (e) {
      log('${e.toString()}');
      return <String, dynamic>{};
    }
  }

  static Map<String, dynamic> handleWeb(AppState appState, Locale locale) {
    String keyString = '/translation_${locale.languageCode}.json';

    Map<String, dynamic> _localizedValues = <String, dynamic>{};

    if (!appState.fileConfig.files.containsKey(keyString) &&
        appState.translationConfig.possibleTranslations.isNotEmpty) {
      keyString = '/translation.json';
    } else if (appState.translationConfig.possibleTranslations.isEmpty) {
      throw Exception('Could not load translation.');
    }

    List<dynamic> jsonList = json.decode(appState.fileConfig.files[keyString]!);

    for (final translation in jsonList) {
      _localizedValues.putIfAbsent(
          translation[textKey], () => translation[translationKey]);
    }

    return _localizedValues;
  }

  static Map<String, dynamic> handleMobile(AppState appState, Locale locale) {
    String keyString = 'translation_${locale.languageCode}.json';

    if (appState.translationConfig.possibleTranslations.isNotEmpty &&
        !appState.translationConfig.possibleTranslations
            .containsKey(keyString)) {
      keyString = 'translation.json';
    } else if (appState.translationConfig.possibleTranslations.isEmpty) {
      throw Exception('Could not load translation.');
    }

    final file =
        File(appState.translationConfig.possibleTranslations[keyString]!);

    String contents = file.readAsStringSync();

    Map<String, dynamic> _localizedValues = <String, dynamic>{};

    if (contents.isNotEmpty) {
      List<dynamic> translationList = json.decode(contents);

      for (final translation in translationList) {
        _localizedValues.putIfAbsent(
            translation[textKey], () => translation[translationKey]);
      }
    }

    return _localizedValues;
  }
}
