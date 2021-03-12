import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../injection_container.dart';
import '../../../models/api/request.dart';
import '../../../models/api/request/application_style.dart';
import '../../../models/api/request/download.dart';
import '../../../models/api/request/startup.dart';
import '../../../models/api/response.dart';
import '../../../models/api/response/application_style_response.dart';
import '../../../models/api/response/menu_item.dart';
import '../../../models/app/app_state.dart';
import '../../../models/app/login_arguments.dart';
import '../../../models/app/menu_arguments.dart';
import '../../../models/app/settings_arguments.dart';
import '../../../services/local/local_database/i_offline_database_provider.dart';
import '../../../services/local/shared_preferences_manager.dart';
import '../../../services/remote/bloc/api_bloc.dart';
import '../../../utils/app/should_download.dart';
import '../../../utils/config/app_config.dart';
import '../../../utils/config/config.dart';
import '../../../utils/theme/get_color_from_app_style.dart';
import '../../../utils/theme/theme_manager.dart';
import '../../../utils/translation/app_localizations.dart';
import '../../../utils/translation/supported_locale_manager.dart';
import '../../pages/login_page.dart';
import '../../pages/menu_page.dart';
import '../../pages/settings_page.dart';
import '../dialogs/dialogs.dart';
import '../util/app_state_provider.dart';
import '../util/error_handling.dart';
import '../util/shared_pref_provider.dart';

class StartupPageWidget extends StatefulWidget {
  final Config config;
  final bool shouldLoadConfig;

  const StartupPageWidget({Key key, this.config, this.shouldLoadConfig})
      : super(key: key);

  @override
  _StartupPageWidgetState createState() => _StartupPageWidgetState();
}

class _StartupPageWidgetState extends State<StartupPageWidget> {
  Response welcomeScreen;
  SharedPreferencesManager manager;
  AppState appState;

  Future<void> _updateDataFromConfig(Future<Config> configFuture) async {
    Config config = await configFuture;

    this.appState.config = config;

    if (config?.debug != null && config.debug) {
      if (config.appName == null || !config.appName.isNotEmpty) {
        await showError(context, 'Error in Config',
            'Please enter a valid application name in conf.json and restart the app.');
      }
      if (config.baseUrl == null || !config.baseUrl.isNotEmpty) {
        await showError(context, 'Error in Config',
            'Please enter a valid base url in conf.json and restart the app.');
      } else if (config.baseUrl.endsWith('/'))
        await showError(context, 'Config Error',
            'Please delete the "/" at the end of the baseUrl and restart the App.');

      this.manager.setAppData(appName: config.appName, baseUrl: config.baseUrl);
      appState.appName = config.appName;
      appState.baseUrl = config.baseUrl;

      if (config.username != null &&
          config.username.isNotEmpty &&
          (appState.username == null || appState.username.isEmpty)) {
        appState.username = config.username;
      }

      if (config.password != null &&
          config.password.isNotEmpty &&
          (appState.password == null || appState.password.isEmpty)) {
        appState.password = config.password;
      }

      if (config.appMode != null && config.appMode.isNotEmpty)
        appState.appMode = config.appMode;
    }
  }

  _updateDataFromSystem() {
    appState.translation = this.manager.translation;

    if (appState.translation != null && appState.translation.isNotEmpty) {
      appState.supportedLocales =
          List<Locale>.from(appState.translation.keys.map((key) {
        if (key.contains('_'))
          return Locale(key.substring(key.indexOf('_') + 1, key.indexOf('.')));
        else
          return Locale('en');
      }));
    }

    if (this.manager.appData['appName'] != null &&
        this.manager.appData['appName'].isNotEmpty) {
      appState.appName = this.manager.appData['appName'];
    }
    if (this.manager.appData['baseUrl'] != null &&
        this.manager.appData['baseUrl'].isNotEmpty) {
      appState.baseUrl = this.manager.appData['baseUrl'];
    }
    if (this.manager.appData['language'] != null &&
        this.manager.appData['language'].isNotEmpty) {
      appState.language = this.manager.appData['language'];
    }
    if (this.manager.appData['picSize'] != null) {
      appState.picSize = this.manager.appData['picSize'];
    }
    if (this.manager.mobileOnly != null) {
      appState.mobileOnly = this.manager.mobileOnly;
    }
  }

  String _getDeviceId() {
    if (this.manager.deviceId != null) {
      return this.manager.deviceId;
    }

    String genDeviceId = Uuid().v1();
    this.manager.setDeviceId(genDeviceId);
    return genDeviceId;
  }

  void _startup(Response response) {
    if (response != null &&
        response.request.requestType == RequestType.STARTUP &&
        response.applicationMetaData != null &&
        response.language != null) {
      if (response.userData != null) {
        if (response.userData.userName != null) {
          appState.username = response.userData.userName;
        }
        if (response.userData.displayName != null) {
          appState.displayName = response.userData.displayName;
        }

        if (response.userData.profileImage != null)
          appState.profileImage = response.userData.profileImage;

        if (response.userData.roles != null) {
          appState.roles = response.userData.roles;
        }
      }
      if (response.applicationMetaData != null &&
          response.applicationMetaData.version != this.manager.appVersion) {
        this.manager.setPreviousAppVersion(this.manager.appVersion);
        this.manager.setAppVersion(response.applicationMetaData.version);
      }

      AppConfig.loadFile().then((AppConfig config) {
        if (config != null) {
          appState.handleSessionTimeout = config.handleSessionTimeout;
          appState.rememberMeChecked = config.rembemerMeChecked ?? false;
        }
      });

      this.appState.clientId = response.applicationMetaData.clientId;
      this.appState.language = response.applicationMetaData.langCode;
      this.appState.appVersion = response.applicationMetaData.version;

      if (appState.language != null && appState.language.isNotEmpty)
        AppLocalizations.load(Locale(this.appState.language));

      ApplicationStyle applicationStyle = ApplicationStyle(
          clientId: response.applicationMetaData.clientId,
          requestType: RequestType.APP_STYLE,
          name: 'applicationStyle',
          contentMode: 'json');

      BlocProvider.of<ApiBloc>(context).add(applicationStyle);

      _checkForScreen(response);
    }
  }

  void _applicationStyle(Response response) async {
    if (response?.request?.requestType == RequestType.APP_STYLE) {
      if (response.applicationStyle != null &&
          response.applicationStyle.themeColor != null) {
        this.appState.applicationStyle = response.applicationStyle;

        MaterialColor newColor =
            getColorFromAppStyle(response.applicationStyle);

        sl<ThemeManager>().themeData = ThemeData(
          primaryColor: newColor,
          primarySwatch: newColor,
          brightness: Brightness.light,
          fontFamily: 'Raleway',
          cursorColor: newColor,
        );

        this.manager.setApplicationStyle(response.applicationStyle.toJson());

        if (response.applicationStyle.hash !=
                this.manager.applicationStylingHash ||
            await shouldDownload(this.appState)) {
          this
              .manager
              .setApplicationStylingHash(response.applicationStyle.hash);
          _download(response);
        } else {
          _checkForLogin(response);
        }
      }
    }
  }

  void _download(Response response) {
    Download translation = Download(
        applicationImages: false,
        libraryImages: false,
        clientId: this.appState.clientId,
        name: 'translation',
        requestType: RequestType.DOWNLOAD_TRANSLATION);

    BlocProvider.of<ApiBloc>(context).add(translation);

    Download images = Download(
        applicationImages: true,
        libraryImages: true,
        clientId: this.appState.clientId,
        contentMode: kIsWeb ? 'base64' : null,
        name: 'images',
        requestType: RequestType.DOWNLOAD_IMAGES);

    BlocProvider.of<ApiBloc>(context).add(images);
  }

  void _login(Response response) {
    Navigator.of(context).pushReplacementNamed(LoginPage.route,
        arguments: LoginArguments(response?.loginItem?.username ?? ''));
  }

  void _menu(Response response) {
    Navigator.of(context).pushReplacementNamed(MenuPage.route,
        arguments: MenuArguments(
            response?.menu?.entries ?? <MenuItem>[], true, this.welcomeScreen));
  }

  void _checkForLogin(Response response) {
    if (response != null && response?.loginItem != null ||
        (this.appState.isOffline &&
            ((this.manager.loginData['username'] == null ||
                    this.manager.loginData['password'] == null) &&
                this.manager.authKey == null))) {
      return _login(response);
    } else if (response?.menu != null || this.appState.isOffline) {
      return _menu(response);
    }
  }

  void _checkForScreen(Response response) {
    if (response?.responseData?.screenGeneric != null) {
      this.welcomeScreen = response;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    this.manager = SharedPrefProvider.of(context).manager;
    this.appState = AppStateProvider.of(context).appState;

    _updateDataFromSystem();

    if (widget.shouldLoadConfig)
      _updateDataFromConfig(Config.loadFile(conf: widget.config))
          .then((value) => _requestStartup());
    else if (widget.config != null &&
        widget.config.debug != null &&
        widget.config.debug) {
      appState.config = widget.config;
      appState.appName = widget.config.appName;
      appState.baseUrl = widget.config.baseUrl;
      appState.username = widget.config.username;
      appState.password = widget.config.password;
      appState.appMode = widget.config.appMode;
      _requestStartup();
    } else
      _requestStartup();
  }

  void _requestStartup() async {
    String languageToServer;

    if (appState.language != null && appState.language.isNotEmpty) {
      languageToServer = appState.language;
    } else {
      languageToServer = kIsWeb
          ? window.locale.languageCode
          : Platform.localeName.substring(0, 2);
    }

    if ((appState.appName == null || appState.appName.isEmpty) ||
        (appState.baseUrl == null || appState.baseUrl.isEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(SettingsPage.route,
              arguments: SettingsArguments(warmWelcome: true));
        }
      });
      return;
    }

    if (this.manager.isOffline != null && this.manager.isOffline) {
      this.appState.applicationStyle =
          ApplicationStyleResponse.fromJson(this.manager.applicationStyle);

      this.appState.offline = this.manager.isOffline;

      if (this.manager.applicationStyle != null &&
          this.manager.applicationStyle.isNotEmpty) {
        MaterialColor newColor = getColorFromAppStyle(
            ApplicationStyleResponse.fromJson(this.manager.applicationStyle));

        sl<ThemeManager>().themeData = ThemeData(
          primaryColor: newColor,
          primarySwatch: newColor,
          brightness: Brightness.light,
          fontFamily: 'Raleway',
          cursorColor: newColor,
        );
      }
    }

    if (this.appState.isOffline) {
      if (!kIsWeb) {
        if (Platform.isIOS) {
          this.appState.dir = (await getApplicationSupportDirectory()).path;
        } else {
          this.appState.dir = (await getApplicationDocumentsDirectory()).path;
        }
      } else {
        this.appState.dir = '';
      }

      String path = this.appState.dir + "/offlineDB.db";

      await sl<IOfflineDatabaseProvider>().openCreateDatabase(path);

      _checkForLogin(null);
    } else {
      Startup startup = Startup(
          url: appState.baseUrl,
          applicationName: appState.appName,
          screenHeight: MediaQuery.of(context).size.height.toInt(),
          screenWidth: MediaQuery.of(context).size.width.toInt(),
          appMode: appState.appMode != null && appState.appMode.isNotEmpty
              ? appState.appMode
              : 'full',
          readAheadLimit: appState.readAheadLimit,
          requestType: RequestType.STARTUP,
          deviceId: _getDeviceId(),
          userName: appState.username,
          password: appState.password,
          authKey: this.manager.authKey,
          layoutMode: 'generic',
          language: languageToServer);

      BlocProvider.of<ApiBloc>(context).add(startup);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApiBloc, Response>(
      listener: (BuildContext context, Response response) {
        if (response.hasError) {
          handleError(response, context);
        } else {
          if (response.restart != null) {
            showRestart(context, 'App will restart', response.restart.info);
          }

          if (response.request.requestType == RequestType.STARTUP)
            _startup(response);
          else if (response.request.requestType == RequestType.APP_STYLE)
            _applicationStyle(response);
          else if (response.request.requestType ==
              RequestType.DOWNLOAD_TRANSLATION) {
            sl<SupportedLocaleManager>().value = this.appState.supportedLocales;
          } else if (response.request.requestType ==
                  RequestType.DOWNLOAD_IMAGES &&
              (response.loginItem != null || response.menu != null))
            _checkForLogin(response);
        }
      },
      child: widget.config?.startupWidget != null
          ? widget.config?.startupWidget
          : Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(appState.package
                              ? 'packages/jvx_flutterclient/assets/images/bg.png'
                              : 'assets/images/bg.png'),
                          fit: BoxFit.cover)),
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Center(
                            child: Image.asset(
                              appState.package
                                  ? 'packages/jvx_flutterclient/assets/images/ss.png'
                                  : 'assets/images/ss.png',
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
            ),
    );
  }
}
