
import 'package:flutter/material.dart';

import 'translation_helper.dart';

class AppLocalizations {
  final Locale locale;
  static Map<String, dynamic> _localizedValues = <String, dynamic>{};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Future<AppLocalizations> load(Locale locale) async {
    _localizedValues = TranslationHelper.loadTranslation(locale);

    if (_localizedValues.isNotEmpty) {
      return AppLocalizations(locale);
    } else {
      return AppLocalizations(const Locale('en'));
    }
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
