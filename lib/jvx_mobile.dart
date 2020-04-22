import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'utils/text_utils.dart';
import 'ui/page/settings_page.dart';
import 'ui/page/startup_page.dart';
import 'utils/config.dart';
import 'utils/translations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class JvxMobile extends StatelessWidget {
  final bool loadConf;
  final ThemeData theme;
  final Config config;

  JvxMobile(this.loadConf, this.theme, {this.config});

  GestureDetector materialApp(BuildContext context, ThemeData theme) =>
      GestureDetector(
          onTap: () => TextUtils.unfocusCurrentTextfield(context),
          child: MaterialApp(
            title: 'JVx Mobile',
            theme: theme,
            debugShowCheckedModeBanner: false,
            showPerformanceOverlay: false,
            //home: StartupPage(),
            localizationsDelegates: [
              const TranslationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale("en", "US"),
              const Locale("de", "DE")
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => StartupPage(this.loadConf, config: this.config,),
              '/settings': (context) => SettingsPage(),
            },
          ));

  @override
  Widget build(BuildContext context) {
    return materialApp(context, this.theme);
  }
}
