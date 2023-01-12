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
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:universal_io/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../config/api/api_route.dart';
import '../../../../exceptions/invalid_server_response_exception.dart';
import '../../../../exceptions/session_expired_exception.dart';
import '../../../../flutter_ui.dart';
import '../../../../model/api_interaction.dart';
import '../../../../model/command/api/alive_command.dart';
import '../../../../model/command/api/changes_command.dart';
import '../../../../model/request/api_alive_request.dart';
import '../../../../model/request/api_change_password_request.dart';
import '../../../../model/request/api_changes_request.dart';
import '../../../../model/request/api_close_frame_request.dart';
import '../../../../model/request/api_close_screen_request.dart';
import '../../../../model/request/api_close_tab_request.dart';
import '../../../../model/request/api_delete_record_request.dart';
import '../../../../model/request/api_device_status_request.dart';
import '../../../../model/request/api_download_images_request.dart';
import '../../../../model/request/api_download_request.dart';
import '../../../../model/request/api_download_style_request.dart';
import '../../../../model/request/api_download_translation_request.dart';
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
import '../../../../model/request/api_request.dart';
import '../../../../model/request/api_reset_password_request.dart';
import '../../../../model/request/api_rollback_request.dart';
import '../../../../model/request/api_save_request.dart';
import '../../../../model/request/api_select_record_request.dart';
import '../../../../model/request/api_set_value_request.dart';
import '../../../../model/request/api_set_values_request.dart';
import '../../../../model/request/api_startup_request.dart';
import '../../../../model/request/api_upload_request.dart';
import '../../../../model/request/download_request.dart';
import '../../../../model/request/session_request.dart';
import '../../../../model/response/api_response.dart';
import '../../../../model/response/application_meta_data_response.dart';
import '../../../../model/response/application_parameters_response.dart';
import '../../../../model/response/application_settings_response.dart';
import '../../../../model/response/authentication_data_response.dart';
import '../../../../model/response/bad_client_response.dart';
import '../../../../model/response/close_frame_response.dart';
import '../../../../model/response/close_screen_response.dart';
import '../../../../model/response/dal_data_provider_changed_response.dart';
import '../../../../model/response/dal_fetch_response.dart';
import '../../../../model/response/dal_meta_data_response.dart';
import '../../../../model/response/device_status_response.dart';
import '../../../../model/response/download_action_response.dart';
import '../../../../model/response/download_images_response.dart';
import '../../../../model/response/download_response.dart';
import '../../../../model/response/download_style_response.dart';
import '../../../../model/response/download_translation_response.dart';
import '../../../../model/response/generic_screen_view_response.dart';
import '../../../../model/response/language_response.dart';
import '../../../../model/response/login_view_response.dart';
import '../../../../model/response/menu_view_response.dart';
import '../../../../model/response/upload_action_response.dart';
import '../../../../model/response/user_data_response.dart';
import '../../../../model/response/view/message/error_view_response.dart';
import '../../../../model/response/view/message/message_dialog_response.dart';
import '../../../../model/response/view/message/message_view.dart';
import '../../../../model/response/view/message/session_expired_response.dart';
import '../../../../util/external/retry.dart';
import '../../../../util/import_handler/import_handler.dart';
import '../../../command/i_command_service.dart';
import '../../../config/config_service.dart';
import '../../../ui/i_ui_service.dart';
import '../api_object_property.dart';
import '../api_response_names.dart';
import '../i_repository.dart';

typedef ResponseFactory = ApiResponse Function(Map<String, dynamic> json);

/// Handles all possible requests to the mobile server.
class OnlineApiRepository implements IRepository {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all remote request mapped to their route
  static final Map<Type, APIRoute Function(ApiRequest pRequest)> uriMap = {
    ApiStartUpRequest: (_) => APIRoute.POST_STARTUP,
    ApiLoginRequest: (_) => APIRoute.POST_LOGIN,
    ApiCloseTabRequest: (_) => APIRoute.POST_CLOSE_TAB,
    ApiDeviceStatusRequest: (_) => APIRoute.POST_DEVICE_STATUS,
    ApiOpenScreenRequest: (_) => APIRoute.POST_OPEN_SCREEN,
    ApiOpenTabRequest: (_) => APIRoute.POST_SELECT_TAB,
    ApiPressButtonRequest: (_) => APIRoute.POST_PRESS_BUTTON,
    ApiSetValueRequest: (_) => APIRoute.POST_SET_VALUE,
    ApiSetValuesRequest: (_) => APIRoute.POST_SET_VALUES,
    ApiChangePasswordRequest: (_) => APIRoute.POST_CHANGE_PASSWORD,
    ApiResetPasswordRequest: (_) => APIRoute.POST_RESET_PASSWORD,
    ApiNavigationRequest: (_) => APIRoute.POST_NAVIGATION,
    ApiReloadMenuRequest: (_) => APIRoute.POST_MENU,
    ApiFetchRequest: (_) => APIRoute.POST_FETCH,
    ApiLogoutRequest: (_) => APIRoute.POST_LOGOUT,
    ApiFilterRequest: (_) => APIRoute.POST_FILTER,
    ApiInsertRecordRequest: (_) => APIRoute.POST_INSERT_RECORD,
    ApiSelectRecordRequest: (_) => APIRoute.POST_SELECT_RECORD,
    ApiCloseScreenRequest: (_) => APIRoute.POST_CLOSE_SCREEN,
    ApiDeleteRecordRequest: (_) => APIRoute.POST_DELETE_RECORD,
    ApiDownloadImagesRequest: (_) => APIRoute.POST_DOWNLOAD,
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
    ApiSaveRequest: (_) => APIRoute.POST_SAVE,
    ApiReloadRequest: (_) => APIRoute.POST_RELOAD,
    ApiRollbackRequest: (_) => APIRoute.POST_ROLLBACK,
  };

  static final Map<String, ResponseFactory> maps = {
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
  };

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Whether we ever had a connection
  bool _everConnected = false;
  bool _connected = false;

  /// Header fields, used for sessionId
  final Map<String, String> _headers = {"Access-Control_Allow_Origin": "*"};

  /// Cookies used for sessionId
  final Set<Cookie> _cookies = {};

  /// Maps response names with a corresponding factory
  late final Map<String, ResponseFactory> responseFactoryMap = maps;

  static const String boundary = "--dart-http-boundary--";

  /// A regular expression that matches strings that are composed entirely of
  /// ASCII-compatible characters.
  final _asciiOnly = RegExp(r'^[\x00-\x7F]+$');

  /// Http client for outgoing connection
  HttpClient? client;

  int _lastDelay = 0;
  Timer? _reconnectTimer;

  JVxWebSocket? jvxWebSocket;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OnlineApiRepository();

  @override
  Future<void> start() async {
    if (isStopped()) {
      client ??= HttpClient()..connectionTimeout = Duration(seconds: ConfigService().getAppConfig()!.requestTimeout!);
      // WebSocket gets started in first request after startup as soon as we get an clientId.
    }
  }

  @override
  Future<void> stop() async {
    // Cancel reconnects
    _cancelHTTPReconnect();
    await stopWebSocket();
    hideStatus();

    _everConnected = false;
    _connected = false;

    client?.close();
    client = null;
  }

  @override
  bool isStopped() {
    return client == null;
  }

  void setConnected(bool connected) {
    if (_connected != connected) {
      FlutterUI.logAPI.i("$runtimeType ${connected ? "connected" : "disconnected"}");
    }

    if (_connected && !connected) {
      // Only show on first reconnect attempt
      showStatus("Server Connection lost, retrying...", true);
      _reconnectHTTP();
    } else if (!_connected && connected && _everConnected) {
      showStatus("Server Connection restored");
    } else if (_connected != connected) {
      hideStatus();
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
  }

  void _reconnectHTTP() {
    _lastDelay = min(_lastDelay + 5, 30);
    FlutterUI.logAPI.i("Retrying HTTP Alive request in $_lastDelay seconds...");
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _lastDelay), () async {
      try {
        await ICommandService().sendCommand(AliveCommand(reason: "Periodic check", retryRequest: false));
        // The CommandService already resets the connected state and the timer.
        FlutterUI.logAPI.i("Alive Request succeeded");
      } on SocketException catch (e, stack) {
        FlutterUI.logAPI.w("Alive Request failed", e, stack);
        _reconnectHTTP();
      }
    });
  }

  void _cancelHTTPReconnect() {
    _lastDelay = 0;

    if (_reconnectTimer != null) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      FlutterUI.logAPI.i("Canceled HTTP reconnect");
    }
  }

  bool isWebSocketAvailable() {
    return jvxWebSocket?.available ?? false;
  }

  Future<void> startWebSocket() async {
    await stopWebSocket();
    return (jvxWebSocket = JVxWebSocket(this)).startWebSocket();
  }

  Future<void> stopWebSocket() async {
    jvxWebSocket?.dispose();
    jvxWebSocket = null;
  }

  void showStatus(String message, [bool showIndefinitely = false]) {
    if (!ConfigService().isOffline()) {
      // If we would want it in the splash too.
      BuildContext? effectiveContext = FlutterUI.getCurrentContext(); //?? FlutterUI.getSplashContext();
      if (effectiveContext != null) {
        ScaffoldMessenger.maybeOf(effectiveContext)?.hideCurrentSnackBar();
        ScaffoldMessenger.maybeOf(effectiveContext)?.showSnackBar(SnackBar(
          content: Text(FlutterUI.translate(message)),
          backgroundColor: (Theme.of(effectiveContext).snackBarTheme.backgroundColor ??
                  Theme.of(effectiveContext).colorScheme.onSurface)
              .withOpacity(0.7),
          // There is no infinite.
          duration: showIndefinitely ? const Duration(days: 365) : const Duration(seconds: 2),
        ));
      }
    }
  }

  void hideStatus() {
    BuildContext? effectiveContext = FlutterUI.getCurrentContext() ?? FlutterUI.getSplashContext();
    if (effectiveContext != null) {
      ScaffoldMessenger.maybeOf(effectiveContext)?.hideCurrentSnackBar();
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Set<Cookie> getCookies() => _cookies;

  @override
  Map<String, String> getHeaders() => _headers;

  @override
  Future<ApiInteraction> sendRequest(ApiRequest pRequest, [bool? retryRequest]) async {
    if (isStopped()) throw Exception("Repository not initialized");

    try {
      if (pRequest is SessionRequest) {
        if (ConfigService().getClientId()?.isNotEmpty == true) {
          pRequest.clientId = ConfigService().getClientId()!;
        } else {
          throw Exception("No Client ID found while trying to send ${pRequest.runtimeType}");
        }
      }

      HttpClientResponse response;
      try {
        if (retryRequest ?? true) {
          response = await retry(
            () => _sendRequest(pRequest),
            retryIf: (e) => e is SocketException,
            retryIfResult: (response) => response.statusCode == 503,
            onRetry: (e) => FlutterUI.logAPI.w("Retrying failed request: ${pRequest.runtimeType}", e),
            onRetryResult: (response) => FlutterUI.logAPI.w("Retrying failed request (503): ${pRequest.runtimeType}"),
            maxAttempts: 3,
            maxDelay: Duration(seconds: ConfigService().getAppConfig()!.requestTimeout!),
          );
        } else {
          response = await _sendRequest(pRequest);
        }
        setConnected(true);
      } catch (_) {
        setConnected(false);
        rethrow;
      }

      if (response.statusCode >= 400 && response.statusCode <= 599) {
        var body = await _decodeBody(response);
        FlutterUI.logAPI.e("Server sent HTTP ${response.statusCode}: $body");
        if (response.statusCode == 404) {
          throw InvalidServerResponseException("Application not found (404)", response.statusCode);
        } else if (response.statusCode == 410) {
          throw SessionExpiredException(response.statusCode);
        } else if (response.statusCode == 500) {
          throw InvalidServerResponseException("General Server Error (500)", response.statusCode);
        } else {
          throw InvalidServerResponseException("Request Error (${response.statusCode}):\n$body", response.statusCode);
        }
      }

      // Download Request needs different handling
      if (pRequest is DownloadRequest) {
        var parsedDownloadObject = _handleDownload(
            pBody: Uint8List.fromList(await response.expand((element) => element).toList()), pRequest: pRequest);
        return parsedDownloadObject;
      }

      String responseBody = await _decodeBody(response);

      if (IUiService().getAppManager() != null) {
        var overrideResponse = await IUiService().getAppManager()?.handleResponse(
              pRequest,
              responseBody,
              () => _sendRequest(pRequest),
            );
        if (overrideResponse != null) {
          response = overrideResponse;
          responseBody = await _decodeBody(overrideResponse);
        }
      }

      List<dynamic> jsonResponse = [];

      if (response.statusCode != 204) {
        if (response.headers.contentType?.value != ContentType.json.value) {
          throw FormatException("Invalid server response"
              "\nType: ${response.headers.contentType?.subType}"
              "\nStatus: ${response.statusCode}");
        }
        jsonResponse = _parseAndCheckJson(responseBody);
      }

      ApiInteraction apiInteraction = _responseParser(jsonResponse, request: pRequest);

      IUiService().getAppManager()?.modifyResponses(apiInteraction);

      if (ConfigService().isOffline()) {
        var viewResponse = apiInteraction.responses.firstWhereOrNull((element) => element is MessageView);
        if (viewResponse != null) {
          var messageViewResponse = viewResponse as MessageView;
          throw StateError("Server sent error: $messageViewResponse");
        }
      }

      return apiInteraction;
    } catch (_) {
      FlutterUI.logAPI.e("Error while sending ${pRequest.runtimeType}");
      rethrow;
    }
  }

  Future<String> _decodeBody(HttpClientResponse response) {
    return response.transform(utf8.decoder).join();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Send post request to remote server, applies timeout.
  Future<HttpClientResponse> _sendRequest(ApiRequest pRequest) async {
    APIRoute? route = uriMap[pRequest.runtimeType]?.call(pRequest);

    if (route == null) {
      throw Exception("URI belonging to ${pRequest.runtimeType} not found, add it to the apiConfig!");
    }

    Uri uri = Uri.parse("${ConfigService().getBaseUrl()!}/${route.route}");
    HttpClientRequest request = await createRequest(uri, route.method);

    if (kIsWeb) {
      if (request is BrowserHttpClientRequest) {
        // Handles cookies in browser
        request.browserCredentialsMode = true;
      }
    } else {
      _cookies.forEach((value) => request.cookies.add(value));
    }

    IUiService().getAppManager()?.modifyCookies(request.cookies);

    _headers.forEach((key, value) => request.headers.set(key, value));
    IUiService().getAppManager()?.modifyHeaders(request.headers);

    if (pRequest is ApiUploadRequest) {
      request.headers.contentType = ContentType(
        "multipart",
        "form-data",
        charset: "utf-8",
        parameters: {"boundary": boundary},
      );
      var content = _addContent(
        {
          "clientId": pRequest.clientId,
          "fileId": pRequest.fileId,
        },
        {"data": pRequest.file},
        boundary,
      );
      // await request.addStream(content);
      // Workaround https://github.com/dint-dev/universal_io/issues/35
      await for (List<int> c in content) {
        request.add(c);
      }
    } else if (route.method != Method.GET) {
      request.headers.contentType = ContentType("application", "json", charset: "utf-8");
      request.write(jsonEncode(pRequest));
    }

    HttpClientResponse res = await request.close();

    if (!kIsWeb) {
      // Extract the session-id cookie to be sent in future
      _cookies.addAll(res.cookies);
    }
    return res;
  }

  Future<HttpClientRequest> createRequest(Uri pUri, Method method) {
    switch (method) {
      case Method.GET:
        return client!.getUrl(pUri);
      case Method.PUT:
        return client!.putUrl(pUri);
      case Method.HEAD:
        return client!.headUrl(pUri);
      case Method.POST:
        return client!.postUrl(pUri);
      case Method.PATCH:
        return client!.patchUrl(pUri);
      case Method.DELETE:
        return client!.deleteUrl(pUri);
      default:
        return client!.postUrl(pUri);
    }
  }

  bool isPlainAscii(String value) {
    return _asciiOnly.hasMatch(value);
  }

  String _headerForField(String name, String value) {
    var header = 'content-disposition: form-data; name="$name"';
    if (!isPlainAscii(value)) {
      header = '$header\r\n'
          'content-type: text/plain; charset=utf-8\r\n'
          'content-transfer-encoding: binary';
    }
    return '$header\r\n\r\n';
  }

  String _headerForFile(String field, String fileName) {
    var header = 'content-type: ${ContentType('application', 'octet-stream')}\r\n'
        'content-disposition: form-data; name="$field"; filename="$fileName"';
    return '$header\r\n\r\n';
  }

  Stream<List<int>> _addContent(Map<String, String> fields, Map<String, XFile> files, String boundary) async* {
    const line = [13, 10]; // \r\n
    final separator = utf8.encode('--$boundary\r\n');
    final close = utf8.encode('--$boundary--\r\n');

    for (var field in fields.entries) {
      yield separator;
      yield utf8.encode(_headerForField(field.key, field.value));
      yield utf8.encode(field.value);
      yield line;
    }

    for (final file in files.entries) {
      yield separator;
      yield utf8.encode(_headerForFile(file.key, basename(file.value.path)));
      yield* Stream.fromIterable([await file.value.readAsBytes()]);
      yield line;
    }
    yield close;
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
  ApiInteraction _responseParser(List<dynamic> pJsonList, {required ApiRequest? request}) {
    List<ApiResponse> returnList = [];

    for (dynamic responseItem in pJsonList) {
      ResponseFactory? builder = responseFactoryMap[responseItem[ApiObjectProperty.name]];

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

class JVxWebSocket {
  final OnlineApiRepository _repository;

  /// Web Socket for incoming connection
  WebSocketChannel? _webSocket;

  /// Describes the current status of the currently active websocket.
  ///
  /// Yes there can be multiple, because we can't close them reliably...
  bool _connected = false;

  /// If we know that the current server has an web socket available.
  bool _available = false;

  /// Current retry delay, gets doubled after ever failed attempt until 60.
  int _retryDelay = 0;

  /// Controls if we should try to reconnect after the socket closes.
  bool _manualClose = false;

  Timer? _reconnectTimer;

  JVxWebSocket(this._repository);

  bool get available => _available;

  /// Not reliable without a readyState
  bool get connected => _connected;

  Future<void> startWebSocket() async {
    await stopWebSocket();
    return _openWebSocket();
  }

  Future<void> stopWebSocket() async {
    _retryDelay = 0;

    if (_reconnectTimer != null) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      FlutterUI.logAPI.i("Canceled WebSocket reconnect");
    }

    await _closeWebSocket();
  }

  FutureOr<void> dispose() async {
    await stopWebSocket();
  }

  Uri _getWebSocketUri() {
    Uri location = Uri.parse(ConfigService().getBaseUrl()!);

    const String subPath = "/services/mobile";
    int? end = location.path.lastIndexOf(subPath);
    if (end == -1) end = null;

    return location.replace(
      scheme: location.scheme == "https" ? "wss" : "ws",
      path: "${location.path.substring(0, end)}/pushlistener",
      queryParameters: {
        "clientId": ConfigService().getClientId()!,
        // Reconnect forces the server to respond to invalid session with close instead of an error.
        "reconnect": true.toString(),
        "confirmOpen": true.toString(),
      },
    );
  }

  Future<void> _openWebSocket() async {
    await _closeWebSocket();

    if (ConfigService().getClientId() == null) {
      FlutterUI.logAPI.i("Canceled WebSocket connect because clientId is missing");
      return;
    }

    var uri = _getWebSocketUri();
    try {
      FlutterUI.logAPI.i("Connecting to WebSocket on $uri");

      var webSocket = _webSocket = createWebSocket(
        uri,
        {
          "Cookie": _repository.getCookies().map((e) => "${e.name}=${e.value}").join(";"),
        },
      );

      webSocket.stream.listen(
        (data) {
          // Block all state changes for non-active web sockets.
          if (_webSocket != webSocket) return;

          _available = true;
          if (!_connected) {
            // onReady
            FlutterUI.logAPI.i("Connected to WebSocket#${webSocket.hashCode}");

            _connected = true;
            _retryDelay = 2;
            _manualClose = false;
          }

          // Re-set to possibly override a single failing http request.
          _repository.setConnected(true);

          if (data.isNotEmpty) {
            try {
              FlutterUI.logAPI.d("Received data via WebSocket#${webSocket.hashCode}: $data");
              if (data == "api/changes") {
                ICommandService().sendCommand(ChangesCommand(reason: "Server sent api/changes"));
              }
            } catch (e, stack) {
              FlutterUI.logAPI.e("Error handling websocket message:", e, stack);
            }
          }
        },
        onError: (error) {
          // As there is no cancel of a currently connection websocket (yet),
          // this is only triggered when the connection websocket fails to initially connect.
          FlutterUI.logAPI.w("Connection to WebSocket#${webSocket.hashCode} failed", error);
          if (_webSocket != webSocket) return;

          _connected = false;

          if (error is WebSocketChannelException &&
              error.inner is WebSocketChannelException &&
              (error.inner as WebSocketChannelException).inner is WebSocketException) {
            // Server probably doesn't support web sockets.
            _available = false;
            FlutterUI.logAPI.i("Connection to WebSocket#${webSocket.hashCode} was determined as unavailable");
          } else {
            _reconnectWebSocket();
          }
        },
        onDone: () {
          FlutterUI.logAPI.w(
            "Connection to WebSocket#${webSocket.hashCode} closed ${_manualClose ? "manually " : ""}(${webSocket.closeCode})${webSocket.closeReason?.isNotEmpty ?? false ? ": ${webSocket.closeReason}" : ""}",
          );
          if (_webSocket != webSocket) return;

          _connected = false;
          _retryDelay = 2;

          if (webSocket.closeCode != status.policyViolation) {
            // Invalid session shouldn't trigger a offline warning.
            //
            // The following scenario can happen:
            // Connection gets interrupted (trying reconnect)
            // Server restarts in the meantime (Session gets invalid)
            // Connections gets restored but clientId is invalid
            // Connection is ready but Web Socket gets closed because of invalid session
            _repository.setConnected(false);
          }

          // Don't retry if server goes down because the clientId will be invalid anyway, which triggers a restart on its own.
          // Don't retry if we closed the socket (indicated either trough manualClose or status.normalClosure)
          if (!_manualClose &&
              ![status.normalClosure, status.goingAway, status.policyViolation].contains(webSocket.closeCode)) {
            _reconnectWebSocket();
          }

          _manualClose = false;
        },
        cancelOnError: true,
      );
    } catch (e) {
      FlutterUI.logAPI.e("Connection to WebSocket could not be established!", e);
      rethrow;
    }
  }

  void _reconnectWebSocket() {
    _retryDelay = min(_retryDelay << 1, 60);
    FlutterUI.logAPI.i("Retrying WebSocket connection in $_retryDelay seconds...");
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _retryDelay), () {
      FlutterUI.logAPI.i("Retrying WebSocket connection");
      _openWebSocket();
    });
  }

  Future<void> _closeWebSocket() async {
    // Only needed for `onError`
    if (_webSocket != null && _connected) {
      _manualClose = true;
    }

    // Workaround for never finishing future in some cases
    // https://github.com/dart-lang/web_socket_channel/issues/231
    try {
      await _webSocket?.sink.close(WebSocketStatus.normalClosure, "Client stopped").timeout(const Duration(seconds: 2));
    } on TimeoutException catch (_) {
    } finally {
      _connected = false;
    }
  }
}
