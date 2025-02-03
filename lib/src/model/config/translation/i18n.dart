/*
 * Copyright 2022-2023 SIB Visions GmbH
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

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../flutter_ui.dart';
import '../../../service/config/i_config_service.dart';
import '../../../service/file/file_manager.dart';
import '../../../util/jvx_logger.dart';

class I18n {
  static final RegExp langRegex = RegExp("_(?<name>[a-z]+)");

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Describes the currently loaded language.
  final ValueNotifier<String?> _currentLanguage = ValueNotifier(null);

  /// Map of all local translations, key is english base text, value is their respective translation.
  final Map<String, String> _localTranslations = {};

  /// Map of all app translations, key is english base text, value is their respective translation.
  final Map<String, String> _translations = {};

  static Future<Iterable<String>> listLocalTranslationFiles() async {
    final Map<String, dynamic> manifestMap =
        await rootBundle.loadString("AssetManifest.json").then((s) => jsonDecode(s));
    return manifestMap.keys.where((e) => _checkPath(e));
  }

  static bool _checkPath(String e) =>
      e.startsWith("packages/flutter_jvx/assets/languages") || e.startsWith("assets/languages");

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  I18n();

  /// The currently active language, if present.
  ValueListenable<String?> get currentLanguage => _currentLanguage;

  /// Translates [text] using the currently active translations.
  ///
  /// Falls back to local translations if there is no app-specific translation.
  ///
  /// Returns the original value if no translation was found.
  String translate(String text) {
    return _translations[text] ?? translateLocal(text);
  }

  /// Translates [text] using the currently active local-only translations.
  ///
  /// Returns the original value if no translation was found.
  String translateLocal(String text) {
    return _localTranslations[text] ?? text;
  }

  /// Sets the language as the currently in use and tries to load all applicable translations.
  Future<void> setLanguage(String lang) async {
    clear();
    _currentLanguage.value = lang;

    await _loadBundledTranslations(lang);
    await _loadAppTranslations(lang);
  }

  void clear() {
    _currentLanguage.value = null;
    _localTranslations.clear();
    _translations.clear();
  }

  /// Loads the locally bundled translations.
  Future<void> _loadBundledTranslations(String lang) async {
    Iterable<String> keys = await listLocalTranslationFiles();

    String? path = keys.firstWhereOrNull((e) => _checkPath(e) && e.endsWith("/translation_$lang.json"));
    if (path != null) {
      _localTranslations.addAll(_extractTranslations(await rootBundle.loadString(path)));
    }
  }

  /// Loads app-specific translations requires a working file manager.
  ///
  /// See also:
  /// * [IFileManager.isSatisfied]
  Future<void> _loadAppTranslations(String lang) async {
    void addFromFile(File? file) {
      if (file != null) {
        _translations.addAll(_extractTranslations(file.readAsStringSync()));
      }
    }

    var fileManager = IConfigService().getFileManager();
    if (!fileManager.isSatisfied()) return;

    // Load the default translation.
    String defaultTransFilePath = fileManager.getAppSpecificPath("${IFileManager.LANGUAGES_PATH}/translation.json");
    File? defaultTransFile = fileManager.getFileSync(defaultTransFilePath);
    addFromFile(defaultTransFile);

    if (lang != "en") {
      String transFilePath = fileManager.getAppSpecificPath("${IFileManager.LANGUAGES_PATH}/translation_$lang.json");
      File? transFile = fileManager.getFileSync(transFilePath);
      if (transFile == null) {
        if (FlutterUI.logUI.cl(Lvl.w)) {
          FlutterUI.logUI.w("Translation file for code $lang could not be found.");
        }
      } else {
        addFromFile(transFile);
      }
    }
  }

  /// Extracts translations from [content].
  static Map<String, String> _extractTranslations(String content) {
    var translations = jsonDecode(content) as List<dynamic>;

    Map<String, String> mapped = {};
    for (var a in translations) {
      if (a['text'] != null) {
        mapped[a['text']] = a['translation'] ?? "";
      }
    }
    return mapped;
  }
}
