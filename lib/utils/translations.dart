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
    _localizedValues = null;
  }

  Locale locale;
  static Map<dynamic, dynamic> _localizedValues;

  static Translations of(BuildContext context) {
    return Localizations.of<Translations>(context, Translations);
  }

  String text(String key) {
    return _localizedValues[key] ?? '** $key not found';
  }

  static Future<Translations> load(Locale locale) async {
    print("Language Code: ${locale.languageCode}");
    try {
      Translations translations = new Translations(locale);
      String jsonContent =
        await rootBundle.loadString("locale/i18n_${locale.languageCode}.json");
      _localizedValues = json.decode(jsonContent);
      
      XmlLoader().loadTranslationsXml(locale.languageCode);

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

  Future<Map<String, String>> loadTranslationsXml(String lang) {
    Future.delayed(const Duration(seconds: 5), () async {
      if (lang == 'en') {
        File file;

        if (globals.translation != null)
          file = new File(globals.translation['translation.xml']);

        String contents = await file.readAsString();

        xml.XmlDocument doc = xml.parse(contents);

        this.currentXml = doc;

        Map<String, String> translation = Map<String, String>();

        this.currentXml.findAllElements('entry').map((f) {
          translation[f.getAttribute('key')] = f.text;
        });

        return translation;
      }
      if (globals.translation['translation_$lang.xml'] != null) {
        File file = new File(globals.translation['translation_$lang.xml']);

        String contents = await file.readAsString();

        xml.XmlDocument doc = xml.parse(contents);

        this.currentXml = doc;

        Map<String, String> translation = Map<String, String>();

        this.currentXml.findAllElements('entry').map((f) {
          translation[f.getAttribute('key')] = f.text;
        });

        return translation;
      }

      return null;
    });

    return null;
  }
}
