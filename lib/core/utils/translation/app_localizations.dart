import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

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

    String contents;
    File file;

    try {
      if (!kIsWeb) {
        if (locale.languageCode == 'en' &&
            appState.translation['translation.xml'] != null) {
          file = File(appState.translation['translation.xml']);
          if (file.existsSync()) {
            contents = file.readAsStringSync();
          }
        } else if (locale.languageCode != 'en' &&
            appState.translation['translation_${locale.languageCode}.xml'] !=
                null) {
          file = File(
              appState.translation['translation_${locale.languageCode}.xml']);

          if (file.existsSync()) {
            contents = file.readAsStringSync();
          }
        } else {
          try {
            String jsonContent =
                await rootBundle.loadString('locale/i18n_de.json');
            _localizedValues = json.decode(jsonContent);
          } catch (e) {
            throw new Error();
          }
        }
      } else {
        contents = appState.files[appState.translation[
            locale.languageCode == 'en'
                ? 'translation.xml'
                : 'translation_${locale.languageCode}.xml']];
      }
    } catch (e) {
      AppLocalizations translations = new AppLocalizations(const Locale('en'));
      String jsonContent = await rootBundle.loadString("locale/i18n_de.json");
      _localizedValues = json.decode(jsonContent);

      return translations;
    }

    if (contents != null && contents.length > 0) {
      XmlDocument doc = XmlDocument.parse(contents);

      doc.findAllElements('entry').toList().forEach((element) {
        _localizedValues[element.attributes.first.value] = element.text;
      });
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
