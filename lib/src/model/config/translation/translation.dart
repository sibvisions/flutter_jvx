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
}

/// Extract translations from file
HashMap<String, String> _getTranslationsFromFile(File file) {
  var translations = jsonDecode(file.readAsStringSync()) as List<dynamic>;

  HashMap<String, String> mapped = HashMap();
  for (var a in translations) {
    mapped[a["text"]] = a["translation"];
  }
  return mapped;
}
