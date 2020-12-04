import 'package:flutter/material.dart';

class SupportedLocaleManager extends ValueNotifier<List<Locale>> {
  static List<Locale> defaultSupportedLocales = <Locale>[
    const Locale('en'),
    const Locale('de')
  ];

  SupportedLocaleManager([List<Locale> initialSupportedLocales])
      : super(initialSupportedLocales ?? defaultSupportedLocales);
}
