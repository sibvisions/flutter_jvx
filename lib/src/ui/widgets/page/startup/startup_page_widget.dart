import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../../injection_container.dart';
import '../../../../models/api/requests/application_style_request.dart';
import '../../../../models/api/requests/download_images_request.dart';
import '../../../../models/api/requests/download_translation_request.dart';
import '../../../../models/api/requests/startup_request.dart';
import '../../../../models/api/response_objects/application_meta_data_response_object.dart';
import '../../../../models/api/response_objects/application_style/application_style_response_object.dart';
import '../../../../models/api/response_objects/device_status_response_object.dart';
import '../../../../models/api/response_objects/language_response_object.dart';
import '../../../../models/api/response_objects/login_response_object.dart';
import '../../../../models/api/response_objects/menu/menu_response_object.dart';
import '../../../../models/api/response_objects/response_data/screen_generic_response_object.dart';
import '../../../../models/api/response_objects/user_data_response_object.dart';
import '../../../../models/state/app_state.dart';
import '../../../../models/state/routes/arguments/login_page_arguments.dart';
import '../../../../models/state/routes/arguments/menu_page_arguments.dart';
import '../../../../models/state/routes/routes.dart';
import '../../../../services/local/locale/supported_locale_manager.dart';
import '../../../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../../../services/remote/cubit/api_cubit.dart';
import '../../../../util/app/get_package_string.dart';
import '../../../../util/color/get_color_from_app_style.dart';
import '../../../../util/device_info/device_info.dart';
import '../../../../util/download/download_helper.dart';
import '../../../../util/theme/theme_manager.dart';
import '../../../../util/translation/app_localizations.dart';
import '../../../util/error/custom_bloc_listener.dart';

class StartupPageWidget extends StatefulWidget {
  final AppState appState;
  final SharedPreferencesManager manager;
  final Widget? startupWidget;

  const StartupPageWidget(
      {Key? key,
      required this.appState,
      required this.manager,
      this.startupWidget})
      : super(key: key);

  @override
  _StartupPageWidgetState createState() => _StartupPageWidgetState();
}

class _StartupPageWidgetState extends State<StartupPageWidget> {
  /// Variable holding the welcome screen if a welcome screen is in the response.
  ApiResponse? startupResponse;

  /// Own cubit instance to avoid multiple calls on the listener.
  late ApiCubit cubit;

  /// Getter for initial language which gets send to the server.
  String get _startupLanguage {
    String language = 'en';

    if (widget.appState.language?.language != null) {
      language = widget.appState.language!.language;
    } else {
      if (!kIsWeb) {
        language = Platform.localeName.substring(0, 2);
      } else {
        language = 'en';
      }
    }

    return language;
  }

  /// Method for sending the [Startup] request.
  void _sendStartupRequest() {
    DeviceInfo deviceInfo = DeviceInfo();

    if (widget.appState.serverConfig != null &&
        widget.appState.serverConfig!.baseUrl.isNotEmpty &&
        widget.appState.serverConfig!.appName.isNotEmpty) {
      StartupRequest request = StartupRequest(
          url: widget.appState.serverConfig!.baseUrl,
          appName: widget.appState.serverConfig!.appName,
          layoutMode: 'generic',
          screenWidth: MediaQuery.of(context).size.width.toInt(),
          screenHeight: MediaQuery.of(context).size.height.toInt(),
          appMode: widget.appState.serverConfig!.appMode,
          readAheadLimit: widget.appState.readAheadLimit,
          deviceId: _getDeviceId(),
          language: _startupLanguage,
          clientId: '',
          deviceMode: kIsWeb ? 'desktop' : 'mobile',
          technology: deviceInfo.technology,
          osName: deviceInfo.osName,
          osVersion: deviceInfo.osVersion,
          appVersion: deviceInfo.appVersion,
          deviceType: deviceInfo.deviceType,
          deviceTypeModel: deviceInfo.deviceTypeModel,
          authKey: widget.manager.authKey,
          username: widget.appState.serverConfig!.username,
          password: widget.appState.serverConfig!.password);

      // For handling the initial Config
      widget.appState.serverConfig!.username = null;
      widget.appState.serverConfig!.password = null;

      cubit.startup(request);
    }
  }

  /// Returns the device id generated on first start.
  String _getDeviceId() {
    if (widget.manager.deviceId != null) {
      return widget.manager.deviceId!;
    }

    String generatedDeviceId = Uuid().v1();
    widget.manager.deviceId = generatedDeviceId;
    return generatedDeviceId;
  }

  /// Sets data returned from the [Startup] request.
  void _setAppStateData(ApiResponse response) {
    widget.appState.applicationMetaData =
        response.getObjectByType<ApplicationMetaDataResponseObject>();
    widget.appState.language =
        response.getObjectByType<LanguageResponseObject>();
    widget.appState.deviceStatus =
        response.getObjectByType<DeviceStatusResponseObject>();

    widget.appState.userData =
        response.getObjectByType<UserDataResponseObject>();
    widget.manager.userData =
        response.getObjectByType<UserDataResponseObject>();

    if (widget.appState.language != null &&
        widget.appState.language!.language.isNotEmpty) {
      widget.manager.language = widget.appState.language!.language;
      AppLocalizations.load(Locale(widget.appState.language!.language));
    }

    if (widget.appState.applicationMetaData != null) {
      ApplicationStyleRequest applicationStyleRequest = ApplicationStyleRequest(
        clientId: widget.appState.applicationMetaData!.clientId,
      );

      cubit.applicationStyle(applicationStyleRequest);
    }
  }

  void _setLocalData() {
    if (widget.appState.applicationMetaData != null &&
        widget.manager.appVersion !=
            widget.appState.applicationMetaData?.version) {
      widget.manager.previousAppVersion = widget.manager.appVersion;
      widget.manager.appVersion = widget.appState.applicationMetaData?.version;
    }
  }

  void _updateDataFromSystem() {
    if (widget.manager.possibleTranslations != null) {
      widget.appState.translationConfig.possibleTranslations =
          widget.manager.possibleTranslations!;
    }

    if (widget.manager.savedImages != null) {
      widget.appState.fileConfig.images = widget.manager.savedImages!;
    }

    if (widget.manager.userData != null) {
      widget.appState.userData = widget.manager.userData;
    }

    if (widget.manager.picSize != null) {
      widget.appState.picSize = widget.manager.picSize!;
    }

    if (!widget.appState.mobileOnly)
      widget.appState.mobileOnly = widget.manager.mobileOnly;

    if (!widget.appState.webOnly)
      widget.appState.webOnly = widget.manager.webOnly;

    if (widget.manager.language != null &&
        widget.manager.language!.isNotEmpty) {
      widget.appState.language = LanguageResponseObject(
          name: 'language',
          language: widget.manager.language!,
          languageResource: '');
    }

    if (widget.appState.translationConfig.possibleTranslations.isNotEmpty) {
      widget.appState.translationConfig.supportedLocales = List<Locale>.from(
          widget.appState.translationConfig.possibleTranslations.keys
              .map((key) {
        if (key.contains('_'))
          return Locale(key.substring(key.indexOf('_') + 1, key.indexOf('.')));
        else
          return Locale('en');
      }));

      WidgetsBinding.instance!.addPostFrameCallback((_) =>
          sl<SupportedLocaleManager>().value =
              widget.appState.translationConfig.supportedLocales);
    }
  }

  void _setAppStyle(ApiResponse response) async {
    if (response.hasObject<ApplicationStyleResponseObject>()) {
      widget.appState.applicationStyle =
          response.getObjectByType<ApplicationStyleResponseObject>();

      // Setting theme for the whole application.
      sl<ThemeManager>().value = ThemeData(
        primaryColor: widget.appState.applicationStyle!.themeColor,
        primarySwatch: getColorFromAppStyle(widget.appState.applicationStyle!),
        brightness: Brightness.light,
      );

      widget.manager.applicationStyle = widget.appState.applicationStyle;

      if (widget.appState.applicationStyle?.hash !=
              widget.manager.applicationStyleHash ||
          await DownloadHelper.isDownloadNeded(DownloadHelper.getLocalFilePath(
              baseUrl: widget.appState.serverConfig!.baseUrl,
              appName: widget.appState.serverConfig!.appName,
              appVersion: widget.appState.applicationMetaData!.version,
              translation: true,
              baseDir: widget.appState.baseDirectory))) {
        widget.manager.applicationStyleHash =
            widget.appState.applicationStyle?.hash;

        _downloadTranslation();
      } else {
        _checkForLogin(startupResponse!);
      }
    }
  }

  void _downloadTranslation() {
    DownloadTranslationRequest request = DownloadTranslationRequest(
        clientId: widget.appState.applicationMetaData!.clientId);

    cubit.downloadTranslation(request);
  }

  void _downloadImages() {
    DownloadImagesRequest request = DownloadImagesRequest(
        clientId: widget.appState.applicationMetaData!.clientId);

    cubit.downloadImages(request);
  }

  void _checkForLogin(ApiResponse response) {
    ModalRoute? route = ModalRoute.of(context);

    if (route != null && route.isCurrent) {
      if (response.hasObject<MenuResponseObject>()) {
        Navigator.of(context).pushReplacementNamed(Routes.menu,
            arguments: MenuPageArguments(
                menuItems:
                    response.getObjectByType<MenuResponseObject>()!.entries,
                listMenuItemsInDrawer: true,
                response: response.hasObject<ScreenGenericResponseObject>()
                    ? response
                    : null));
      } else {
        Navigator.of(context).pushReplacementNamed(Routes.login,
            arguments: LoginPageArguments(
                lastUsername:
                    response.getObjectByType<LoginResponseObject>()!.username));
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)!.isCurrent) {
      _updateDataFromSystem();

      _sendStartupRequest();
    }
  }

  @override
  void initState() {
    super.initState();

    cubit = ApiCubit.withDependencies();
  }

  @override
  void dispose() {
    cubit.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomCubitListener(
            handleError: true,
            handleLoading: false,
            appState: widget.appState,
            bloc: cubit,
            listener: (context, state) {
              if (state is ApiResponse) {
                if (state.request is StartupRequest) {
                  startupResponse = state;

                  _setAppStateData(state);

                  _setLocalData();
                } else if (state.request is ApplicationStyleRequest) {
                  _setAppStyle(state);
                } else if (state.request is DownloadTranslationRequest) {
                  AppLocalizations.load(
                      Locale(widget.appState.language!.language));

                  _downloadImages();
                } else if (state.request is DownloadImagesRequest) {
                  _checkForLogin(startupResponse!);
                }
              }
            },
            child: widget.startupWidget != null
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
                                    getPackageString(widget.appState,
                                        'assets/images/ss.png'),
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
                  )));
  }
}
