import 'package:flutter/material.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:flutterclient/src/models/api/response_objects/menu/menu_item.dart';
import 'package:flutterclient/src/models/state/routes/arguments/login_page_arguments.dart';
import 'package:flutterclient/src/models/state/routes/arguments/menu_page_arguments.dart';
import 'package:flutterclient/src/models/state/routes/routes.dart';
import 'package:flutterclient/src/util/download/download_helper.dart';
import '../../../../../injection_container.dart';
import '../../../../models/api/response_objects/application_style/application_style_response_object.dart';
import '../../../../models/api/response_objects/language_response_object.dart';
import '../../../../models/api/response_objects/user_data_response_object.dart';
import '../../../../models/state/app_state.dart';
import '../../../../services/local/local_database/i_offline_database_provider.dart';
import '../../../../services/local/locale/supported_locale_manager.dart';
import '../../../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../../../util/app/get_package_string.dart';
import '../../../../util/color/get_color_from_app_style.dart';
import '../../../../util/theme/theme_manager.dart';

class OfflineStartupPageWidget extends StatefulWidget {
  final AppState appState;
  final SharedPreferencesManager manager;
  final Widget? startupWidget;

  const OfflineStartupPageWidget(
      {Key? key,
      required this.appState,
      required this.manager,
      this.startupWidget})
      : super(key: key);

  @override
  _OfflineStartupPageWidgetState createState() =>
      _OfflineStartupPageWidgetState();
}

class _OfflineStartupPageWidgetState extends State<OfflineStartupPageWidget> {
  void _loadData() {
    ApplicationStyleResponseObject? appStyle = widget.manager.applicationStyle;

    if (appStyle != null) {
      widget.appState.applicationStyle = appStyle;

      WidgetsBinding.instance!.addPostFrameCallback((_) {
        sl<ThemeManager>().value = ThemeData(
          primaryColor: widget.appState.applicationStyle!.themeColor,
          primarySwatch:
              getColorFromAppStyle(widget.appState.applicationStyle!),
          brightness: Brightness.light,
        );
      });
    }

    widget.appState.language = LanguageResponseObject(
        language: widget.manager.language ?? 'en', languageResource: '');

    widget.appState.picSize = widget.manager.picSize ?? 320;

    widget.appState.mobileOnly = widget.manager.mobileOnly;
    widget.appState.webOnly = widget.manager.webOnly;

    widget.appState.applicationMetaData = widget.manager.applicationMetaData;

    Map<String, String>? translations = widget.manager.possibleTranslations;

    if (translations != null && translations.isNotEmpty) {
      widget.appState.translationConfig.possibleTranslations = translations;

      widget.appState.translationConfig.supportedLocales = List<Locale>.from(
          widget.appState.translationConfig.possibleTranslations.keys
              .map((key) {
        if (key.contains('_'))
          return Locale(key.substring(key.indexOf('_') + 1, key.indexOf('.')));
        else
          return Locale('en');
      }));

      WidgetsBinding.instance!.addPostFrameCallback((_) {
        sl<SupportedLocaleManager>().value =
            widget.appState.translationConfig.supportedLocales;
      });
    }

    UserDataResponseObject? userData = widget.manager.userData;

    if (userData != null) {
      widget.appState.userData = userData;
    }
  }

  void _setAppState() {
    widget.appState.isOffline = widget.manager.isOffline;

    DownloadHelper.getBaseDir().then((value) {
      widget.appState.baseDirectory = value;

      final path = widget.appState.baseDirectory + '/offlineDB.db';

      sl<IOfflineDatabaseProvider>().openCreateDatabase(path);

      _checkForLogin();
    });
  }

  void _checkForLogin() {
    if (widget.manager.authKey != null) {
      return _menu();
    } else {
      return _login();
    }
  }

  void _menu() {
    Navigator.of(context).pushReplacementNamed(Routes.menu,
        arguments: MenuPageArguments(
            listMenuItemsInDrawer: true, menuItems: <MenuItem>[]));
  }

  void _login() {
    Navigator.of(context).pushReplacementNamed(Routes.login,
        arguments:
            LoginPageArguments(lastUsername: '', loginMode: LoginMode.DEFAULT));
  }

  @override
  void initState() {
    super.initState();

    _loadData();

    _setAppState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.startupWidget != null
        ? widget.startupWidget!
        : Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(getPackageString(
                            widget.appState, 'assets/images/bg.png')),
                        fit: BoxFit.cover)),
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Center(
                          child: Image.asset(
                            getPackageString(
                                widget.appState, 'assets/images/ss.png'),
                            width: 135,
                          ),
                        )),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: CircularProgressIndicator()),
                        Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Text('Loading...'))
                      ],
                    )
                  ])
            ],
          );
  }
}
