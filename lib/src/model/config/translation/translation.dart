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

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

class Translation {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all translations, key is english base text, value is translated
  final HashMap<String, String> translations;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Translation.fromFile({required File pFile}) : translations = _getTranslationsFromFile(pFile);

  Translation.empty() : translations = HashMap();

  Translation({
    required this.translations,
  });

  void merge(File? pFile) {
    if (pFile != null) {
      translations.addAll(_getTranslationsFromFile(pFile));
    }
  }
}

/// Extract translations from file
HashMap<String, String> _getTranslationsFromFile(File file) {
  var translations = jsonDecode(file.readAsStringSync()) as List<dynamic>;

  HashMap<String, String> mapped = HashMap();
  for (var a in translations) {
    mapped[a['text']] = a['translation'];
  }
  return mapped;
}
