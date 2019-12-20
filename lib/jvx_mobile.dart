import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/theme_bloc.dart';
import 'package:jvx_mobile_v3/ui/page/settings_page.dart';
import 'package:jvx_mobile_v3/ui/page/startup_page.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class JvxMobile extends StatelessWidget {
  bool loadConf;

  JvxMobile(this.loadConf);

  MaterialApp materialApp(BuildContext context, ThemeData theme) => MaterialApp(
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
        supportedLocales: [const Locale("en", "US"), const Locale("de", "DE")],
        initialRoute: '/',
        routes: {
          '/': (context) => StartupPage(this.loadConf),
          '/settings': (context) => SettingsPage(),
        },
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeData>(builder: (context, state) {
      if (state == null) {
        return materialApp(
            context,
            ThemeData(
                fontFamily: UIData.ralewayFont,
                primarySwatch: UIData.ui_kit_color_2,
                primaryColor: UIData.ui_kit_color_2));
      }
      return materialApp(context, state);
    });
  }
}
