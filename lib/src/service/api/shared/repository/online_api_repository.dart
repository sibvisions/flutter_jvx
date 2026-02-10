/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';
import 'package:universal_io/io.dart';

import '../../../../config/api/api_route.dart';
import '../../../../exceptions/invalid_server_response_exception.dart';
import '../../../../exceptions/view_exception.dart';
import '../../../../flutter_ui.dart';
import '../../../../mask/jvx_overlay.dart';
import '../../../../model/api_interaction.dart';
import '../../../../model/command/api/alive_command.dart';
import '../../../../model/command/api/changes_command.dart';
import '../../../../model/command/api/open_screen_command.dart';
import '../../../../model/command/api/reload_menu_command.dart';
import '../../../../model/request/api_action_request.dart';
import '../../../../model/request/api_activate_screen_request.dart';
import '../../../../model/request/api_alive_request.dart';
import '../../../../model/request/api_cancel_login_request.dart';
import '../../../../model/request/api_change_password_request.dart';
import '../../../../model/request/api_changes_request.dart';
import '../../../../model/request/api_close_content_request.dart';
import '../../../../model/request/api_close_frame_request.dart';
import '../../../../model/request/api_close_screen_request.dart';
import '../../../../model/request/api_close_tab_request.dart';
import '../../../../model/request/api_dal_save_request.dart';
import '../../../../model/request/api_delete_record_request.dart';
import '../../../../model/request/api_device_status_request.dart';
import '../../../../model/request/api_download_images_request.dart';
import '../../../../model/request/api_download_request.dart';
import '../../../../model/request/api_download_style_request.dart';
import '../../../../model/request/api_download_templates_request.dart';
import '../../../../model/request/api_download_translation_request.dart';
import '../../../../model/request/api_exit_request.dart';
import '../../../../model/request/api_feedback_request.dart';
import '../../../../model/request/api_fetch_request.dart';
import '../../../../model/request/api_filter_request.dart';
import '../../../../model/request/api_focus_gained_request.dart';
import '../../../../model/request/api_focus_lost_request.dart';
import '../../../../model/request/api_insert_record_request.dart';
import '../../../../model/request/api_login_request.dart';
import '../../../../model/request/api_logout_request.dart';
import '../../../../model/request/api_mouse_clicked_request.dart';
import '../../../../model/request/api_mouse_pressed_request.dart';
import '../../../../model/request/api_mouse_released_request.dart';
import '../../../../model/request/api_navigation_request.dart';
import '../../../../model/request/api_open_screen_request.dart';
import '../../../../model/request/api_open_tab_request.dart';
import '../../../../model/request/api_press_button_request.dart';
import '../../../../model/request/api_reload_menu_request.dart';
import '../../../../model/request/api_reload_request.dart';
import '../../../../model/request/api_home_request.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/request/api_reset_password_request.dart';
import '../../../../model/request/api_restore_data_request.dart';
import '../../../../model/request/api_save_data_request.dart';
import '../../../../model/request/api_reload_data_request.dart';
import '../../../../model/request/api_rollback_request.dart';
import '../../../../model/request/api_save_request.dart';
import '../../../../model/request/api_select_record_request.dart';
import '../../../../model/request/api_select_record_tree_request.dart';
import '../../../../model/request/api_set_parameter.dart';
import '../../../../model/request/api_set_screen_parameter.dart';
import '../../../../model/request/api_set_value_request.dart';
import '../../../../model/request/api_set_values_request.dart';
import '../../../../model/request/api_sort_request.dart';
import '../../../../model/request/api_startup_request.dart';
import '../../../../model/request/api_upload_request.dart';
import '../../../../model/request/download_request.dart';
import '../../../../model/request/application_request.dart';
import '../../../../model/request/upload_request.dart';
import '../../../../model/response/api_response.dart';
import '../../../../model/response/application_meta_data_response.dart';
import '../../../../model/response/application_parameters_response.dart';
import '../../../../model/response/application_settings_response.dart';
import '../../../../model/response/authentication_data_response.dart';
import '../../../../model/response/bad_client_response.dart';
import '../../../../model/response/close_content_response.dart';
import '../../../../model/response/close_frame_response.dart';
import '../../../../model/response/close_screen_response.dart';
import '../../../../model/response/content_response.dart';
import '../../../../model/response/dal_data_provider_changed_response.dart';
import '../../../../model/response/dal_fetch_response.dart';
import '../../../../model/response/dal_meta_data_response.dart';
import '../../../../model/response/device_status_response.dart';
import '../../../../model/response/download_action_response.dart';
import '../../../../model/response/download_images_response.dart';
import '../../../../model/response/download_response.dart';
import '../../../../model/response/download_style_response.dart';
import '../../../../model/response/download_templates_response.dart';
import '../../../../model/response/download_translation_response.dart';
import '../../../../model/response/generic_screen_view_response.dart';
import '../../../../model/response/language_response.dart';
import '../../../../model/response/login_view_response.dart';
import '../../../../model/response/menu_view_response.dart';
import '../../../../model/response/show_document_response.dart';
import '../../../../model/response/upload_action_response.dart';
import '../../../../model/response/user_data_response.dart';
import '../../../../model/response/view/message/error_view_response.dart';
import '../../../../model/response/view/message/message_dialog_response.dart';
import '../../../../model/response/view/message/message_view.dart';
import '../../../../model/response/view/message/session_expired_response.dart';
import '../../../../util/external/retry.dart';
import '../../../../util/jvx_logger.dart';
import '../../../../util/parse_util.dart';
import '../../../apps/i_app_service.dart';
import '../../../command/i_command_service.dart';
import '../../../command/shared/processor/config/save_application_meta_data_command_processor.dart';
import '../../../config/i_config_service.dart';
import '../../../storage/i_storage_service.dart';
import '../../../ui/i_ui_service.dart';
import '../api_object_property.dart';
import '../api_response_names.dart';
import '../i_repository.dart';
import 'jvx_web_socket.dart';

typedef ResponseFactory = ApiResponse Function(Map<String, dynamic> json);

/// Handles all possible requests to the mobile server.
class OnlineApiRepository extends IRepository {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all remote request mapped to their route
  static final Map<Type, APIRoute Function(ApiRequest pRequest)> uriMap = {
    ApiStartupRequest: (_) => APIRoute.POST_STARTUP,
    ApiLoginRequest: (_) => APIRoute.POST_LOGIN,
    ApiCancelLoginRequest: (_) => APIRoute.POST_CANCEL_LOGIN,
    ApiCloseTabRequest: (_) => APIRoute.POST_CLOSE_TAB,
    ApiDeviceStatusRequest: (_) => APIRoute.POST_DEVICE_STATUS,
    ApiOpenScreenRequest: (pRequest) =>
        (pRequest as ApiOpenScreenRequest).reopen ? APIRoute.POST_REOPEN_SCREEN : APIRoute.POST_OPEN_SCREEN,
    ApiActivateScreenRequest: (_) => APIRoute.POST_ACTIVATE_SCREEN,
    ApiSetParameter: (_) => APIRoute.POST_SET_PARAMETER,
    ApiSetScreenParameter: (_) => APIRoute.POST_SET_SCREEN_PARAMETER,
    ApiOpenTabRequest: (_) => APIRoute.POST_SELECT_TAB,
    ApiPressButtonRequest: (_) => APIRoute.POST_PRESS_BUTTON,
    ApiSetValueRequest: (_) => APIRoute.POST_SET_VALUE,
    ApiActionRequest: (_) => APIRoute.POST_ACTION,
    ApiSetValuesRequest: (_) => APIRoute.POST_SET_VALUES,
    ApiChangePasswordRequest: (_) => APIRoute.POST_CHANGE_PASSWORD,
    ApiResetPasswordRequest: (_) => APIRoute.POST_RESET_PASSWORD,
    ApiRestoreDataRequest: (_) => APIRoute.POST_RESTORE_DATA,
    ApiSaveDataRequest: (_) => APIRoute.POST_SAVE_DATA,
    ApiReloadDataRequest: (_) => APIRoute.POST_RELOAD_DATA,
    ApiNavigationRequest: (_) => APIRoute.POST_NAVIGATION,
    ApiReloadMenuRequest: (_) => APIRoute.POST_MENU,
    ApiFetchRequest: (_) => APIRoute.POST_FETCH,
    ApiLogoutRequest: (_) => APIRoute.POST_LOGOUT,
    ApiFilterRequest: (_) => APIRoute.POST_FILTER,
    ApiSelectRecordTreeRequest: (_) => APIRoute.POST_SELECT_TREE,
    ApiInsertRecordRequest: (_) => APIRoute.POST_INSERT_RECORD,
    ApiSelectRecordRequest: (_) => APIRoute.POST_SELECT_RECORD,
    ApiCloseScreenRequest: (_) => APIRoute.POST_CLOSE_SCREEN,
    ApiDeleteRecordRequest: (_) => APIRoute.POST_DELETE_RECORD,
    ApiDownloadImagesRequest: (_) => APIRoute.POST_DOWNLOAD,
    ApiDownloadTemplatesRequest: (_) => APIRoute.POST_DOWNLOAD,
    ApiDownloadTranslationRequest: (_) => APIRoute.POST_DOWNLOAD,
    ApiDownloadStyleRequest: (_) => APIRoute.POST_DOWNLOAD,
    ApiCloseFrameRequest: (_) => APIRoute.POST_CLOSE_FRAME,
    ApiUploadRequest: (_) => APIRoute.POST_UPLOAD,
    ApiDownloadRequest: (_) => APIRoute.POST_DOWNLOAD,
    ApiChangesRequest: (_) => APIRoute.POST_CHANGES,
    ApiMousePressedRequest: (_) => APIRoute.POST_MOUSE_PRESSED,
    ApiMouseClickedRequest: (_) => APIRoute.POST_MOUSE_CLICKED,
    ApiMouseReleasedRequest: (_) => APIRoute.POST_MOUSE_RELEASED,
    ApiFocusGainedRequest: (_) => APIRoute.POST_FOCUS_GAINED,
    ApiFocusLostRequest: (_) => APIRoute.POST_FOCUS_LOST,
    ApiAliveRequest: (_) => APIRoute.POST_ALIVE,
    ApiExitRequest: (_) => APIRoute.POST_EXIT,
    ApiFeedbackRequest: (_) => APIRoute.POST_FEEDBACK,
    ApiSaveRequest: (_) => APIRoute.POST_SAVE,
    ApiReloadRequest: (_) => APIRoute.POST_RELOAD,
    ApiRollbackRequest: (_) => APIRoute.POST_ROLLBACK,
    ApiHomeRequest: (_) => APIRoute.POST_HOME,
    ApiSortRequest: (_) => APIRoute.POST_SORT,
    ApiCloseContentRequest: (_) => APIRoute.POST_CLOSE_CONTENT,
    ApiDalSaveRequest: (_) => APIRoute.POST_DAL_SAVE,
  };

  static const Map<String, ResponseFactory> maps = {
    ApiResponseNames.applicationMetaData: ApplicationMetaDataResponse.fromJson,
    ApiResponseNames.applicationParameters: ApplicationParametersResponse.fromJson,
    ApiResponseNames.applicationSettings: ApplicationSettingsResponse.fromJson,
    ApiResponseNames.language: LanguageResponse.fromJson,
    ApiResponseNames.closeScreen: CloseScreenResponse.fromJson,
    ApiResponseNames.closeFrame: CloseFrameResponse.fromJson,
    ApiResponseNames.dalFetch: DalFetchResponse.fromJson,
    ApiResponseNames.menu: MenuViewResponse.fromJson,
    ApiResponseNames.screenGeneric: GenericScreenViewResponse.fromJson,
    ApiResponseNames.dalMetaData: DalMetaDataResponse.fromJson,
    ApiResponseNames.userData: UserDataResponse.fromJson,
    ApiResponseNames.login: LoginViewResponse.fromJson,
    ApiResponseNames.messageError: ErrorViewResponse.fromJson,
    ApiResponseNames.sessionExpired: SessionExpiredResponse.fromJson,
    ApiResponseNames.dalDataProviderChanged: DalDataProviderChangedResponse.fromJson,
    ApiResponseNames.authenticationData: AuthenticationDataResponse.fromJson,
    ApiResponseNames.messageDialog: MessageDialogResponse.fromJson,
    ApiResponseNames.deviceStatus: DeviceStatusResponse.fromJson,
    ApiResponseNames.upload: UploadActionResponse.fromJson,
    ApiResponseNames.download: DownloadActionResponse.fromJson,
    ApiResponseNames.badClient: BadClientResponse.fromJson,
    ApiResponseNames.content: ContentResponse.fromJson,
    ApiResponseNames.closeContent: CloseContentResponse.fromJson,
    ApiResponseNames.showDocument: ShowDocumentResponse.fromJson,
  };

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // https://github.com/cfug/dio/blob/main/plugins/cookie_manager/lib/src/cookie_mgr.dart
  final _setCookieReg = RegExp('(?<=)(,)(?=[^;]+?=)');

  // Whether we ever had a connection
  bool _everConnected = false;
  bool _connected = false;

  static const Duration statusDelay = Duration(seconds: 2);
  Timer? _statusTimer;

  /// Fixed header fields
  final Map<String, String> _headers = {"Access-Control_Allow_Origin": "*"};

  /// External cookies
  final Map<String, Cookie> _cookies = {};

  /// Maps response names with a corresponding factory
  final Map<String, ResponseFactory> responseFactoryMap = maps;

  /// Http client for connections
  Dio? client;

  Timer? _aliveTimer;

  int _lastDelay = 0;
  Timer? _reconnectTimer;

  JVxWebSocket? jvxWebSocket;

  bool get connected => _connected;

  /// Whether communication is compressed
  bool compress = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OnlineApiRepository() {
    if (IConfigService().getAppConfig()?.payloadCompress != null) {
      compress = IConfigService().getAppConfig()?.payloadCompress == true;
    }
  }

  /// Initializes the [client].
  ///
  /// Doesn't trigger WebSocket, as it needs a working ClientID and is therefore
  /// only started in the first response handling after the startup.
  ///
  /// See also:
  /// * [SaveApplicationMetaDataCommandProcessor]
  @override
  Future<void> start() async {
    if (isStopped()) {
      client ??= _createClient();
    }
  }

  @override
  Future<void> stop() async {
    await super.stop();

    // Cancel reconnects
    await stopWebSocket();
    _cancelHTTPReconnect();
    resetConnectedStatus(instant: true);

    _everConnected = false;
    _connected = false;

    client?.close();
    client = null;

    // Depends on client field.
    resetAliveInterval();
  }

  @override
  bool isStopped() {
    return client == null;
  }

  Dio _createClient({Uri? baseUrl}) {
    Duration? connectTimeout = ParseUtil.validateDuration(IConfigService().getAppConfig()?.connectTimeout);
    Duration? requestTimeout = ParseUtil.validateDuration(
        IConfigService().getAppConfig()?.requestTimeout ?? IConfigService().getAppConfig()?.connectTimeout);
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl?.toString() ?? '',
      connectTimeout: connectTimeout,
      receiveTimeout: requestTimeout,
      sendTimeout: requestTimeout,
      validateStatus: (status) => true,
      extra: {
        "withCredentials": true,
      },
    );

    return Dio(options)..interceptors.add(DioLogInterceptor(FlutterUI.httpBucket));
  }

  void setConnected(bool connected) {
    if (_connected != connected) {
      FlutterUI.logAPI.i("$runtimeType ${connected ? "connected" : "disconnected"}");
    }

    if (_connected && !connected) {
      // Only show on first reconnect attempt
      _statusTimer = Timer(statusDelay, () {
        setConnectedStatus(false);
      });
      _reconnectHTTP();
    } else if (!_connected && connected && _everConnected) {
      // If last timer is still running, cancel it and don't show new message.
      if (_statusTimer?.isActive ?? false) {
        _statusTimer?.cancel();
      } else {
        setConnectedStatus(true);
      }
      askServerForChanges();
    } else if (_connected != connected) {
      resetConnectedStatus();
    }

    if (connected) {
      _everConnected = true;
      _cancelHTTPReconnect();

      // Bad idea, results in more problems than it solves.
      // E.g. no guarantee for a working session
      // Let the web socket handle such a situation.
      // if (wsAvailable && !wsConnected) {
      //   startWebSocket();
      // }
    }

    _connected = connected;

    // Has to happen after field update, depends on field.
    if (_connected != connected) {
      resetAliveInterval();
    }
  }

  void _reconnectHTTP() {
    _lastDelay = min(_lastDelay + 5, 30);
    FlutterUI.logAPI.i("Retrying HTTP Alive request in $_lastDelay seconds...");
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _lastDelay), () async {
      try {
        await ICommandService().sendCommand(AliveCommand(reason: "Periodic check", retryRequest: false));

        if (connected) {
          // The CommandService already resets the connected state and the timer.
          FlutterUI.logAPI.i("Alive Request succeeded");
        }
        else {
          FlutterUI.logAPI.w("Alive Request not successful, retry");
          _reconnectHTTP();
        }
      } on DioException catch (e, stack) {
        if (_shouldRetryDioRequest(e)) {
          FlutterUI.logAPI.w("Alive Request timed out, retry", error: e, stackTrace: stack);
          _reconnectHTTP();
        }
      } on IOException catch (e, stack) {
        FlutterUI.logAPI.w("Alive Request failed, retry", error: e, stackTrace: stack);
        _reconnectHTTP();
      } catch (e, stack) {
        FlutterUI.logAPI.e("Alive Request failed", error: e, stackTrace: stack);
      }
    });
  }

  bool _shouldRetryDioRequest(DioException e) {
    const timeoutTypes = [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ];

    return timeoutTypes.contains(e.type) ||
        (e.type == DioExceptionType.connectionError && e.message?.contains("XMLHttpRequest") == true);
  }

  void _cancelHTTPReconnect() {
    _lastDelay = 0;

    if (_reconnectTimer != null) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      FlutterUI.logAPI.i("Canceled HTTP reconnect");
    }
  }

  /// Resets the alive timer and restarts if the requirements are fulfilled.
  ///
  /// Requirements:
  /// * HttpClient works ([client] != `null`).
  /// * Connection works ([connected] == `true`).
  /// * Session is valid ([IUiService.clientId] != `null`).
  /// * App is in foreground ([AppLifecycleState] == [AppLifecycleState.resumed]).
  ///
  /// This method is called during the following changes:
  /// * Connection State
  /// * [AppLifecycleState]
  /// * When HTTP request happens
  /// * When repository stops
  void resetAliveInterval() {
    _aliveTimer?.cancel();
    FlutterUI.logAPI.d("Alive Interval reset");

    // Repository stopped.
    if (client == null) return;
    // No connection.
    if (!connected) return;
    // No session.
    if (IUiService().clientId.value == null) return;
    // Are we offline?
    if (IConfigService().offline.value) return;
    // Not in foreground.
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) return;

    var aliveInterval = IConfigService().getAppConfig()!.aliveInterval!;
    if (aliveInterval == Duration.zero || aliveInterval.isNegative) return;

    _aliveTimer = Timer(aliveInterval, () async {
      // No activity happened during interval.
      try {
        await ICommandService().sendCommand(AliveCommand(reason: "Inactivity check", retryRequest: false));
        // The CommandService already resets the connected state and therefore this timer.
      } catch (e, stack) {
        FlutterUI.logAPI.w("Inactivity Alive Request failed", error: e, stackTrace: stack);
      }
    });
    FlutterUI.logAPI.d("Alive Interval started");
  }

  JVxWebSocket? getWebSocket() {
    return jvxWebSocket;
  }

  Future<void> startWebSocket() async {
    await stopWebSocket();

    return (jvxWebSocket = JVxWebSocket(
      uriSupplier: _getWebSocketUri,
      headersSupplier: () {
        List<Cookie>? requestCookies;

        if (!kIsWeb) {
          requestCookies = getCookies().toList();
          IUiService().getAppManager()?.modifyCookies(null, requestCookies);
        }

        Map<String, dynamic> requestHeaders = getHeaders();
        IUiService().getAppManager()?.modifyHeaders(null, requestHeaders);

        return {
          if (requestCookies != null) HttpHeaders.cookieHeader: requestCookies.map((e) => e.toString()).join("; "),
          ...requestHeaders
        };
      },
      connectTimeout: ParseUtil.validateDuration(IConfigService().getAppConfig()?.connectTimeout),
      onData: (data) {
        if (data is Uint8List) {
          try {
            var jsonData = jsonDecode(String.fromCharCodes(data));

            String? command = jsonData["command"];
            String? className = jsonData["arguments"]?["className"];

            if (command == "dyn:relaunch") {
              IAppService().startApp();
            } else if (command == "dyn:reloadCss") {
              // not relevant for mobile
            } else if (command == "dyn:previewScreen" && className != null) {
              String? screenLongName = IUiService().getMenuModel().getMenuItemByClassName(className)?.screenLongName;
              if (screenLongName != null) {
                ICommandService().sendCommand(
                  OpenScreenCommand(
                    className: className,
                    reason: "Open screen because server sent dyn:previewScreen",
                  ),
                );
              } else {
                ICommandService().sendCommand(
                  ReloadMenuCommand(
                    reason: "Reload menu because server sent dyn:previewScreen and screen was unknown",
                  ),
                );
              }
            } else if (command == "api/menu") {
              ICommandService().sendCommand(
                ReloadMenuCommand(
                  reason: "Reload menu because server sent api/menu",
                ),
              );
            } else if (command == "api/reopenScreen" && className != null) {
              if (IStorageService().getComponentByScreenClassName(pScreenClassName: className) != null) {
                ICommandService().sendCommand(
                  OpenScreenCommand(
                    reopen: true,
                    className: className,
                    reason: "Reload/Reopen screen because server sent api/reopenScreen",
                  ),
                );
              }
            }
          } on FormatException {
            // Not a valid json -> ignore and continue
          }
        }

        if (data == "api/changes") {
          ICommandService().sendCommand(ChangesCommand(reason: "Server sent api/changes"), showDialogOnError: false);
        }
      },
      onConnectedChange: (connected) => setConnected(connected),
      pingInterval: IConfigService().getAppConfig()!.wsPingInterval!,
    ))
        .startWebSocket();
  }

  Future<void> stopWebSocket() async {
    jvxWebSocket?.dispose();
    jvxWebSocket = null;
  }

  Uri? _getWebSocketUri() {
    String? clientId = IUiService().clientId.value;

    if (clientId == null) {
      FlutterUI.logAPI.i("WebSocket URI: ClientID is missing");
      return null;
    }

    Uri location = IConfigService().baseUrl.value!;

    int? end = location.path.lastIndexOf(ParseUtil.mobileServicePath);

    if (end == -1) {
      //maybe another service name
      end = location.path.lastIndexOf(ParseUtil.servicePath);
    }

    if (end == -1) {
      end = null;
    }

    return location.replace(
      scheme: location.scheme == "https" ? "wss" : "ws",
      path: "${location.path.substring(0, end)}/pushlistener",
      queryParameters: {
        "clientId": clientId,
        // `reconnect` forces the server to respond to invalid session with close instead of an error.
        "reconnect": true.toString(),
      },
    );
  }

  void setConnectedStatus(bool connected) {
    if (!IConfigService().offline.value) {
      JVxOverlay.maybeOf(FlutterUI.getEffectiveContext())?.setConnectionState(connected);
    }
  }

  void resetConnectedStatus({bool instant = false}) {
    _statusTimer?.cancel();
    JVxOverlay.maybeOf(FlutterUI.getEffectiveContext())?.resetConnectionState(instant: instant);
  }

  /// Triggers a [ChangesCommand] for the case that changes have been dropped during reconnect.
  void askServerForChanges() {
    if (IUiService().clientId.value != null && !IConfigService().offline.value) {
      ICommandService()
          .sendCommand(ChangesCommand(reason: "Check for changes after reconnect"), showDialogOnError: false);
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Set<Cookie> getCookies() {
    return _cookies.values.toSet();
  }

  @override
  void setCookies(Set<Cookie> pCookies) {
    _cookies.clear();

    for (final cookie in pCookies) {
      _cookies[cookie.name] = cookie;
    }
  }

  @override
  Map<String, String> getHeaders() {
    return Map.of(_headers);
  }

  @override
  Future<ApiInteraction> sendRequest(ApiRequest pRequest, [bool? retryRequest]) async {
    _checkStatus();

    try {
      if (cancelledSessionExpired.value && (IUiService().clientId.value?.isEmpty ?? true)) {
        return ApiInteraction(responses: [], request: pRequest);
      }

      /// HttpException can also be an invalid argument, check before retrying.
      ///
      /// Currently known http exceptions:
      /// * HttpException: Connection closed before full header was received, uri = <uri>
      /// * HttpException: Connection closed while receiving data, uri = <uri>
      bool shouldRetry(Object? error) {
        error = (error is DioException ? error.error : null) ?? error;
        return (error is HttpException && error.message.contains("Connection closed"));
      }

      client!.options.baseUrl = IConfigService().baseUrl.value!.toString();
      sendFunction() => _sendRequest(
            pRequest,
            client: client!,
            headers: _headers,
            cookies: _cookies,
            clientId: IUiService().clientId.value,
          );

      Response response;
      try {
        if (retryRequest ?? true) {

          response = await retry(
            sendFunction,
            retryIf: (e) => shouldRetry(e),
            retryIfResult: (response) => response.statusCode == 503,
            onRetry: (e) => FlutterUI.logAPI.w("Retrying failed request: ${pRequest.runtimeType}", error: e),
            onRetryResult: (response) => FlutterUI.logAPI.w("Retrying failed request (${response.statusCode}): ${pRequest.runtimeType}"),
            maxAttempts: 3,
            maxDelay: client?.options.receiveTimeout,
          );
        } else {
          response = await sendFunction();
        }

        setConnected(true);
      } catch (e) {
        if (e is IOException || e is TimeoutException) {
          setConnected(false);
        }
        if (e is DioException && e.error != null) {
          Error.throwWithStackTrace(e.error!, e.stackTrace);
        }
        rethrow;
      } finally {
        // Has to happen after connected field update, depends on field.
        resetAliveInterval();
      }

      if (IUiService().getAppManager() != null) {
        response = await IUiService().getAppManager()!.handleResponse(pRequest, response, sendFunction);
      }

      if (response.statusCode != null && response.statusCode! >= 400 && response.statusCode! <= 599) {
        String body = _decodeUTF8(response.data);

        if (pRequest.ignoreError()) {
          if (FlutterUI.logAPI.cl(Lvl.d)) {
            FlutterUI.logAPI.d("Server sent HTTP ${response.statusCode} but ${pRequest.runtimeType} ignores the error");
          }

          return ApiInteraction(responses: [], request: pRequest);
        }

        if (FlutterUI.logAPI.cl(Lvl.e)) {
          FlutterUI.logAPI.e("Server sent HTTP ${response.statusCode} with body: $body");
        }

        if (response.statusCode == 400 && pRequest is ApiStartupRequest) {
          APIRoute? route = uriMap[pRequest.runtimeType]?.call(pRequest);
          String routeString = route!.route.replaceAll("api", "");
          throw InvalidServerResponseException("Server doesn't support '$routeString'.", response.statusCode);
        } else if (response.statusCode == 404) {
          throw InvalidServerResponseException("Application not found (404)", response.statusCode);
        } else if (response.statusCode == 410) {
          return ApiInteraction(request: pRequest, responses: [SessionExpiredResponse()]);
        } else if (response.statusCode == 500) {
          throw InvalidServerResponseException("General Server Error (500)", response.statusCode);
        } else {
          throw InvalidServerResponseException("Request Error (${response.statusCode}):\n$body", response.statusCode);
        }
      }

      // Download Request needs different handling
      if (pRequest is DownloadRequest) {
        Uint8List body = response.data;
        var parsedDownloadObject = _handleDownload(pBody: body, pRequest: pRequest);
        return parsedDownloadObject;
      }

      List<dynamic> jsonResponse = [];

      if (response.statusCode != 204) {
        var contentTypes = response.headers[Headers.contentTypeHeader];

        if (contentTypes == null
            || contentTypes.contains(ContentType.json.value)
            || contentTypes.contains(ContentType.text.value)) {
          jsonResponse = _parseAndCheckJson(_decodeUTF8(response.data));
        }
        else if (contentTypes.contains(ContentType.binary.value)) {
          compress = true;

          jsonResponse = _parseAndCheckJson(utf8.decode(GZipCodec().decode(response.data)));
        }
        else {
          throw FormatException("Invalid server response\nType: $contentTypes\nStatus: ${response.statusCode}");
        }
      }

      ApiInteraction apiInteraction = _responseParser(jsonResponse, request: pRequest);

      IUiService().getAppManager()?.modifyResponses(apiInteraction);

      if (IConfigService().offline.value) {
        var viewResponse = apiInteraction.responses.firstWhereOrNull((element) => element is MessageView);
        if (viewResponse != null) {
          var messageViewResponse = viewResponse as MessageView;
          throw ViewException("Server sent error: $messageViewResponse");
        }
      }

      return apiInteraction;
    } catch (error, stack) {
      if (FlutterUI.logAPI.cl(Lvl.e)) {
        FlutterUI.logAPI.e("Error while sending ${pRequest.runtimeType}\n\n$error\n\n$stack");
      }

      rethrow;
    }
  }

  Future<Object> _getData(ApiRequest pRequest) async {
    if (pRequest is UploadRequest) {
      if (pRequest is ApiUploadRequest) {
        return FormData.fromMap({
          ...pRequest.toJson(),
          "data": MultipartFile.fromBytes(
            await pRequest.file.readAsBytes(),
            filename: pRequest.file.name,
          ),
        });
      } else {
        throw UnimplementedError("${pRequest.runtimeType} is an unknown UploadRequest.");
      }
    }

    String json = jsonEncode(pRequest);

    if (compress) {
      return GZipCodec().encode(utf8.encode(json));
    }
    else {
      return json;
    }
  }

  /// Sends a single [ApiRequest] by creating a new client, ignoring every response and closing it after.
  Future<void> sendRequestAndForget(ApiRequest pRequest) async {
    Dio? client;
    try {
      client = _createClient(baseUrl: IConfigService().baseUrl.value);
      await _sendRequest(
        pRequest,
        client: client,
        headers: _headers,
        cookies: _cookies,
        clientId: IUiService().clientId.value,
      );
    } finally {
      client?.close();
    }
  }

  String _decodeUTF8(Uint8List responseBytes) {
    return utf8.decode(responseBytes, allowMalformed: true);
  }

  void _checkStatus() {
    if (isStopped()) throw Exception("Repository not initialized");
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Sends request to remote server, applies timeout.
  Future<Response> _sendRequest(
    ApiRequest pRequest, {
    required Dio client,
    required Map<String, Cookie> cookies,
    required Map<String, dynamic> headers,
    required String? clientId,
  }) async {
    if (pRequest is ApplicationRequest && pRequest.clientId == null) {
      if (clientId?.isNotEmpty == true) {
        pRequest.clientId = clientId!;
      } else {
        throw Exception("No Client ID found while trying to send ${pRequest.runtimeType}");
      }
    }

    Object? data = await _getData(pRequest);

    APIRoute? route = uriMap[pRequest.runtimeType]?.call(pRequest);

    if (route == null) {
      throw Exception("URI belonging to ${pRequest.runtimeType} not found, add it to the apiConfig!");
    }

    List<Cookie>? requestCookies;
    if (!kIsWeb) {
      requestCookies = cookies.values.toList();
      IUiService().getAppManager()?.modifyCookies(pRequest, requestCookies);
    }

    Map<String, dynamic> requestHeaders = Map.of(headers);
    IUiService().getAppManager()?.modifyHeaders(pRequest, requestHeaders);

    if (compress) {
      requestHeaders['content-type'] = ContentType.binary.mimeType;
    }

    Uri uri = Uri(path: "/${route.route}");

    if (IUiService().getAppManager() != null) {
      IUiService().getAppManager()!.beforeRequest(pRequest, uri);
    }

    Response response = await client.requestUri(
      uri,
      data: route.method != Method.GET ? data : null,
      options: Options(
        method: route.method.name,
        headers: {
          if (requestCookies != null) HttpHeaders.cookieHeader: requestCookies.map((e) => e.toString()).join("; "),
          ...requestHeaders,
        },
        // To ensure maximum flexibility
        responseType: ResponseType.bytes,
      ),
    );

    if (!kIsWeb) {
      // Extract the cookies for future calls -> especially JSESSIONID is important
      final List<String>? headerValues = response.headers[HttpHeaders.setCookieHeader];
      if (headerValues != null) {
        for (final header in headerValues) {
          // only, if more than one cookie is available in one header line -> split
          List<String> parts = header.split(_setCookieReg);

          for (final part in parts) {
            String partTrim = part.trim();

            if (partTrim.isNotEmpty) {
              Cookie cookie = Cookie.fromSetCookieValue(partTrim);

              //Replace or add cookies
              _cookies[cookie.name] = cookie;
            }
          }
        }
      }
    }

    return response;
  }

  /// Check if response is an error, an error does not come as array, returns
  /// the error in an error.
  List<dynamic> _parseAndCheckJson(String pBody) {
    var response = jsonDecode(pBody);

    if (response is List<dynamic>) {
      return response;
    } else {
      return [response];
    }
  }

  /// Parses the List of JSON responses in [ApiResponse]s
  ApiInteraction _responseParser(List<dynamic> jsonList, {required ApiRequest? request}) {
    List<ApiResponse> returnList = [];

    bool log = FlutterUI.logAPI.cl(Lvl.i);

    for (dynamic responseItem in jsonList) {
      ResponseFactory? builder = responseFactoryMap[responseItem[ApiObjectProperty.name]];

      if (log) {
        FlutterUI.logAPI.d(responseItem);
      }

      if (builder != null) {
        returnList.add(builder(responseItem));
      } else {
        // returnList.add(ErrorResponse(message: "Could not find builder for ${responseItem[ApiObjectProperty.name]}", name: ApiResponseNames.error));
      }
    }

    return ApiInteraction(responses: returnList, request: request);
  }

  ApiInteraction _handleDownload({required Uint8List pBody, required DownloadRequest pRequest}) {
    List<ApiResponse> parsedResponse = [];

    if (pRequest is ApiDownloadImagesRequest) {
      parsedResponse.add(DownloadImagesResponse(
        responseBody: pBody,
        name: ApiResponseNames.downloadImages,
      ));
    } else if (pRequest is ApiDownloadTemplatesRequest) {
      parsedResponse.add(DownloadTemplatesResponse(
        responseBody: pBody,
        name: ApiResponseNames.downloadTemplates,
      ));
    } else if (pRequest is ApiDownloadTranslationRequest) {
      parsedResponse.add(DownloadTranslationResponse(
        bodyBytes: pBody,
        name: ApiResponseNames.downloadTranslation,
      ));
    } else if (pRequest is ApiDownloadStyleRequest) {
      parsedResponse.add(DownloadStyleResponse(
        bodyBytes: pBody,
        name: ApiResponseNames.downloadStyle,
      ));
    } else if (pRequest is ApiDownloadRequest) {
      parsedResponse.add(DownloadResponse(
        bodyBytes: pBody,
        name: ApiResponseNames.downloadResponse,
      ));
    }

    return ApiInteraction(responses: parsedResponse, request: pRequest);
  }
}
