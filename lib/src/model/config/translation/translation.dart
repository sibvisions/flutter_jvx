import 'dart:collection';
import 'dart:io';

class Translation {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Current language code
  final String langCode;

  /// Map of all translations, key is english base text, value is translated
  final HashMap<String, String> translations;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Translation.fromFile({required File pFile})
      : langCode = "asdasd",
        translations = HashMap();
}
