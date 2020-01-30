import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/model/api/request/download.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:path_provider/path_provider.dart';
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
    if (locale.languageCode == 'en') {
      return key;
    }
    return _localizedValues[key];
  }

  String text2(String key, [String defaultValue]) {
    return _localizedValues2[key] ?? text(key) ?? key;
  }

  static Future<Translations> loadWithBuildContext(
      Locale locale, BuildContext context) async {
    Translations translations = new Translations(locale);

    if (globals.translation['translation_${locale.languageCode}.xml'] != null &&
        !(await shouldDownload())) {
      _localizedValues2 =
          XmlLoader().loadTranslationsXml(locale.languageCode, context);
    } else {
      try {
        Translations translations = new Translations(const Locale('en'));
        String jsonContent = await rootBundle.loadString("locale/i18n_de.json");
        _localizedValues = json.decode(jsonContent);

        return translations;
      } catch (e) {
        throw new Error();
      }
    }

    return translations;
  }

  static Future<Translations> load(Locale locale) async {
    Translations translations = new Translations(locale);

    if (globals.translation['translation_${locale.languageCode}.xml'] != null &&
        !(await shouldDownload())) {
      _localizedValues2 = XmlLoader().loadTranslationsXml(locale.languageCode);
    } else {
      try {
        Translations translations = new Translations(const Locale('en'));
        String jsonContent = await rootBundle.loadString(globals.package
            ? "packages/jvx_mobile_v3/locale/i18n_de.json"
            : "locale/i18n_de.json");
        _localizedValues = json.decode(jsonContent);

        return translations;
      } catch (e) {
        print('Translation not found');
        //throw new Error();
      }
    }

    return translations;
  }

  get currentLanguage => locale.languageCode;

  static Future<bool> shouldDownload() async {
    var _dir;

    if (Platform.isIOS) {
      _dir = (await getApplicationSupportDirectory()).path;
    } else {
      _dir = (await getApplicationDocumentsDirectory()).path;
    }

    String trimmedUrl = globals.baseUrl.split('/')[2];
    Directory directory = Directory(
        '$_dir/translations/$trimmedUrl/${globals.appName}/${globals.appVersion}');

    if (directory.existsSync()) {
      return false;
    }
    return true;
  }
}

class TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const TranslationsDelegate();

  @override
  bool isSupported(Locale locale) {
    List<String> suppLangs = <String>[];
    if (globals.translation.length > 0) {
      globals.translation.forEach((k, v) {
        if (k != 'translation.xml') {
          String resTrans = k.substring(12, k.indexOf('.'));

          suppLangs.add(resTrans);
        } else {
          suppLangs.add('en');
        }
      });
    } else {
      suppLangs = ['en', 'de'];
    }

    return suppLangs.contains(locale.languageCode);
  }

  Future<Translations> loadWithBuildContext(
          Locale locale, BuildContext context) =>
      Translations.loadWithBuildContext(locale, context);

  @override
  bool shouldReload(TranslationsDelegate old) => false;

  @override
  Future<Translations> load(Locale locale) => Translations.load(locale);
}

class XmlLoader {
  xml.XmlDocument currentXml;

  XmlLoader();

  Map<String, String> loadTranslationsXml(String lang, [BuildContext context]) {
    if (lang == 'en') {
      File file;
      String contents;

      if (globals.translation['translation.xml'] != null)
        file = new File(globals.translation['translation.xml']);

      if (file.existsSync()) {
        contents = file.readAsStringSync();
      } else {
        print('Error with Loading ${globals.translation["translation.xml"]}');
        print('Starting download...');
        if (context != null) {
          BlocProvider.of(context).dispatch(Download(
              name: 'translation',
              applicationImages: false,
              libraryImages: false,
              clientId: globals.clientId,
              requestType: RequestType.DOWNLOAD_TRANSLATION));
        }
      }

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

      if (file.existsSync()) {
        contents = file.readAsStringSync();
      } else {
        print(
            'Error with Loading ${globals.translation["translation_" + lang + ".xml"]}');
      }

      Map<String, String> translations = <String, String>{};

      if (contents != null && contents.length > 0) {
        xml.XmlDocument doc = xml.parse(contents);

        doc.findAllElements('entry').toList().forEach((e) {
          translations[e.attributes.first.value] = e.text;
        });
      }

      return translations;
    }
    return <String, String>{};
  }
}
