import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart' as xml;
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class Translations {
  Translations(Locale locale) {
    this.locale = locale;
    _localizedValues = Map<dynamic, dynamic>();
    _localizedValues2 = Map<dynamic, dynamic>();
  }

  Locale locale;
  static Map<dynamic, dynamic> _localizedValues;
  static Map<dynamic, dynamic> _localizedValues2;

  static Translations of(BuildContext context) {
    return Localizations.of<Translations>(context, Translations);
  }

  String text(String key) {
    return _localizedValues[key];
  }

  String text2(String key, [String defaultValue]) {
    return _localizedValues2[key] ?? key; // text(key) ?? defaultValue;
  }

  static Future<Translations> load(Locale locale) async {
    try {
      Translations translations = new Translations(locale);
      String jsonContent =
        await rootBundle.loadString("locale/i18n_${locale.languageCode}.json");
      _localizedValues = json.decode(jsonContent);
      
      if (globals.translation['translation_${locale.languageCode}.xml'] != null) {
        _localizedValues2 = XmlLoader().loadTranslationsXml(locale.languageCode);
      }

      return translations;
    } catch (e) {
      Translations translations = new Translations(const Locale('en'));
      String jsonContent =
        await rootBundle.loadString("locale/i18n_en.json");
      _localizedValues = json.decode(jsonContent);
      print('default tranlation loaded');
      return translations;
    }
  }

  get currentLanguage => locale.languageCode;
}

class TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const TranslationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'de'].contains(locale.languageCode);

  @override
  Future<Translations> load(Locale locale) => Translations.load(locale);

  @override
  bool shouldReload(TranslationsDelegate old) => false;
}

class XmlLoader {
  xml.XmlDocument currentXml;

  XmlLoader();

  Map<String, String> loadTranslationsXml(String lang) {
    if (lang == 'en') {
      File file;
      String contents;

      if (globals.translation['translation.xml'] != null)
        file = new File(globals.translation['translation.xml']);
        contents = file.readAsStringSync();

      if (contents != null) {
        xml.XmlDocument doc = xml.parse(contents);

        Map<String, String> translations = <String, String>{};

        doc.findAllElements('entry').toList().forEach((e) {
          translations[e.attributes.first.value] = e.text;
        });

        return translations;
      }
    }
    if (globals.translation['translation_$lang.xml'] != null) {
      File file;
      String contents;

      file = new File(globals.translation['translation_$lang.xml']);
      contents = file.readAsStringSync();

      xml.XmlDocument doc = xml.parse(contents);

      Map<String, String> translations = <String, String>{};

      doc.findAllElements('entry').toList().forEach((e) {
        translations[e.attributes.first.value] = e.text;
      });

      return translations;
    }
    return <String, String>{};
  }
}
