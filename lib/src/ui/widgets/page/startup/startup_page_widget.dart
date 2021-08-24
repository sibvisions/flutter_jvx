import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../login/login_card.dart';
import '../../../../util/device_info/device_info_mobile.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/api/requests/application_style_request.dart';
import '../../../../models/api/requests/download_images_request.dart';
import '../../../../models/api/requests/download_translation_request.dart';
import '../../../../models/api/requests/startup_request.dart';
import '../../../../models/api/response_objects/login_response_object.dart';
import '../../../../models/api/response_objects/menu/menu_response_object.dart';
import '../../../../models/api/response_objects/response_data/screen_generic_response_object.dart';
import '../../../../models/state/app_state.dart';
import '../../../../models/state/routes/arguments/login_page_arguments.dart';
import '../../../../models/state/routes/arguments/menu_page_arguments.dart';
import '../../../../models/state/routes/routes.dart';
import '../../../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../../../services/remote/cubit/api_cubit.dart';
import '../../../../util/app/get_package_string.dart';
import '../../../../util/app/state/state_helper.dart';
import '../../../../util/device_info/device_info.dart';
import '../../../../util/download/download_helper.dart';
import '../../../../util/translation/app_localizations.dart';
import '../../../util/custom_cubit_listener.dart';

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

  late Future startupFuture;

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
  Future<void> _sendStartupRequest() async {
    _updateDataFromSystem();

    DeviceInfo deviceInfo = DeviceInfo();

    if (!kIsWeb) {
      await (deviceInfo as DeviceInfoMobile).setSystemInfo();
    }

    if (widget.appState.serverConfig != null &&
        widget.appState.serverConfig!.baseUrl.isNotEmpty &&
        widget.appState.serverConfig!.appName.isNotEmpty) {
      StartupRequest request = StartupRequest(
          url: widget.appState.serverConfig!.baseUrl,
          appName: widget.appState.serverConfig!.appName,
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
          password: widget.appState.serverConfig!.password,
          parameter: widget.appState.appConfig?.startupParameter ??
              <String, dynamic>{});

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
  void _handleStartupResponse(ApiResponse response) {
    StateHelper.updateAppStateWithStartupResponse(widget.appState, response);

    StateHelper.updateLocalDataWithStartupResponse(widget.manager, response);

    if (widget.appState.applicationMetaData != null) {
      ApplicationStyleRequest applicationStyleRequest = ApplicationStyleRequest(
        clientId: widget.appState.applicationMetaData!.clientId,
      );

      cubit.applicationStyle(applicationStyleRequest);
    }
  }

  void _updateDataFromSystem() {
    StateHelper.updateAppStateWithLocalData(widget.manager, widget.appState);
  }

  void _handleAppStyleResponse(ApiResponse response) async {
    StateHelper.updateAppStateAndLocalDataWithApplicationStyleResponse(
        widget.appState, widget.manager, response);

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
        final loginResponse = response.getObjectByType<LoginResponseObject>()!;

        final loginMode = getLoginMode(loginResponse.mode);

        Navigator.of(context).pushReplacementNamed(Routes.login,
            arguments: LoginPageArguments(
                lastUsername:
                    response.getObjectByType<LoginResponseObject>()!.username,
                loginMode: loginMode));
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) => _sendStartupRequest());

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

                  _handleStartupResponse(state);
                } else if (state.request is ApplicationStyleRequest) {
                  _handleAppStyleResponse(state);
                } else if (state.request is DownloadTranslationRequest) {
                  AppLocalizations.load(
                      Locale(widget.appState.language!.language));

                  _downloadImages();
                } else if (state.request is DownloadImagesRequest) {
                  _checkForLogin(startupResponse!);
                }
              }
            },
            child: Builder(
              builder: (context) {
                if (widget.appState.widgetConfig.startupWidget != null) {
                  return widget.appState.widgetConfig.startupWidget!;
                }

                return Stack(
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
              },
            )));
  }
}
