import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/ui/page/startup_page.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class JvxMobile extends StatelessWidget {
  final materialApp = MaterialApp(
    title: UIData.appName,
    theme: ThemeData(
      primaryColor: Colors.black,
      fontFamily: UIData.quickFont,
      primarySwatch: Colors.amber
    ),
    debugShowCheckedModeBanner: false,
    showPerformanceOverlay: false,
    home: StartupPage(),
    localizationsDelegates: [
      const TranslationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate
    ],
    supportedLocales: [
      const Locale("en", "US"),
      const Locale("de", "DE")
    ],
  );

  @override
  Widget build(BuildContext context) {
    return materialApp;
  }
}