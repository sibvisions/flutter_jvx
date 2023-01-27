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

import 'dart:convert';
import 'dart:io';

class TranslationUtil {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all translations, key is english base text, value is translated
  final Map<String, String> _translations;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  TranslationUtil({
    required Map<String, String> translations,
  }) : _translations = translations;

  TranslationUtil.empty() : _translations = {};

  /// Shortcut for [TranslationUtil.empty] and [merge].
  TranslationUtil.fromFile(File file) : _translations = _loadTranslationsFromFile(file);

  /// Translates [pText] using the current known translations.
  ///
  /// Returns the original value if not translation was found.
  String translateText(String pText) {
    String? translatedText = _translations[pText];
    if (translatedText == null) {
      return pText;
    }
    return translatedText;
  }

  /// Adds the translations provided via [pFile].
  void merge(File? pFile) {
    if (pFile != null) {
      _translations.addAll(_loadTranslationsFromFile(pFile));
    }
  }

  /// Extracts translations from file
  static Map<String, String> _loadTranslationsFromFile(File file) {
    var translations = jsonDecode(file.readAsStringSync()) as List<dynamic>;

    Map<String, String> mapped = {};
    for (var a in translations) {
      mapped[a['text']] = a['translation'];
    }
    return mapped;
  }
}
