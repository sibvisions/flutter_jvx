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
import '../../../../exceptions/session_expired_exception.dart';
import '../../../../flutter_ui.dart';
import '../../../../model/api_interaction.dart';
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

  /// Http client for outgoing connection
  HttpClient? client;

  /// Http client for outside connection
  WebSocketChannel? webSocket;

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

  int lastDelay = 2;
  bool manualClose = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OnlineApiRepository();

  @override
  Future<void> start() async {
    client ??= HttpClient()..connectionTimeout = Duration(seconds: ConfigService().getAppConfig()!.requestTimeout!);
  }

  Future<void> startWebSocket([bool reconnect = false]) async {
    await stopWebSocket();

    if (reconnect && isStopped()) {
      return;
    }

    var uri = _getWebSocketUri(reconnect);
    try {
      FlutterUI.logAPI.i("Connecting to Websocket on $uri");

      webSocket = createWebSocket(
        uri,
        {"Cookie": _cookies.map((e) => "${e.name}=${e.value}").join(";")},
      );

      webSocket!.stream.listen(
        (data) {
          lastDelay = 2;
          manualClose = false;
          if (data.isNotEmpty) {
            try {
              FlutterUI.logAPI.d("Received data via websocket: $data");
              if (data == "api/changes") {
                ICommandService().sendCommand(ChangesCommand(reason: "Server sent api/changes"));
              }
            } catch (e) {
              FlutterUI.logAPI.e("Error handling websocket message:", e);
            }
          }
        },
        onError: (error) {
          FlutterUI.logAPI.w("Connection to Websocket failed", error);

          // Cancel reconnect if manually closed
          if (manualClose) {
            manualClose = false;
            return;
          }

          if (lastDelay == 2) {
            showStatus("Server Connection lost, retrying...");
          }
          reconnectWebSocket();
        },
        onDone: () {
          FlutterUI.logAPI.w(
            "Connection to Websocket closed (${webSocket?.closeCode})${webSocket?.closeReason != null ? ": ${webSocket?.closeReason}" : ""}",
          );

          lastDelay = 2;

          if (!manualClose) {
            if (webSocket?.closeCode != status.abnormalClosure && webSocket?.closeCode != status.goingAway) {
              showStatus("Server Connection lost, retrying...");
              reconnectWebSocket();
            } else {
              showStatus("Server Connection lost");
            }
            manualClose = false;
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      FlutterUI.logAPI.e("Connection to Websocket could not be established!", e);
      rethrow;
    }
  }

  void showStatus(String message) {
    if (!ConfigService().isOffline()) {
      ScaffoldMessenger.of(FlutterUI.getCurrentContext()!).showSnackBar(SnackBar(
        content: Text(message),
      ));
    }
  }

  void reconnectWebSocket() {
    lastDelay = min(lastDelay << 1, 120);
    FlutterUI.logAPI.i("Retrying Websocket connection in $lastDelay seconds...");
    Timer(Duration(seconds: lastDelay), () {
      FlutterUI.logAPI.i("Retrying Websocket connection");
      startWebSocket(true);
    });
  }

  Uri _getWebSocketUri(bool reconnect) {
    Uri location = Uri.parse(ConfigService().getBaseUrl()!);

    const String subPath = "/services/mobile";
    int? end = location.path.lastIndexOf(subPath);
    if (end == -1) end = null;

    return location.replace(
      scheme: location.scheme == "https" ? "wss" : "ws",
      path: "${location.path.substring(0, end)}/pushlistener",
      queryParameters: {
        "clientId": ConfigService().getClientId()!,
        if (reconnect) "reconnect": null,
      },
    );
  }

  Future<void> stopWebSocket() async {
    manualClose = true;
    // Workaround for never finishing future in some cases
    // https://github.com/dart-lang/web_socket_channel/issues/231
    try {
      await webSocket?.sink.close().timeout(const Duration(seconds: 2));
    } on TimeoutException catch (_) {}
  }

  @override
  Future<void> stop() async {
    client?.close();
    client = null;
    await stopWebSocket();
  }

  @override
  bool isStopped() {
    return client == null;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Set<Cookie> getCookies() => _cookies;

  @override
  Map<String, String> getHeaders() => _headers;

  @override
  Future<ApiInteraction> sendRequest(ApiRequest pRequest) async {
    if (isStopped()) throw Exception("Repository not initialized");

    APIRoute? route = uriMap[pRequest.runtimeType]?.call(pRequest);

    if (route != null) {
      try {
        if (pRequest is SessionRequest) {
          if (ConfigService().getClientId()?.isNotEmpty == true) {
            pRequest.clientId = ConfigService().getClientId()!;
          } else {
            throw Exception("No Client ID found while trying to send ${pRequest.runtimeType}");
          }
        }

        HttpClientResponse response = await retry(
          () => _sendPostRequest(route, pRequest),
          retryIf: (e) => e is SocketException,
          retryIfResult: (response) => response.statusCode == 503,
          onRetry: (e) => FlutterUI.logAPI.w("Retrying failed request: ${pRequest.runtimeType}", e),
          onRetryResult: (response) => FlutterUI.logAPI.w("Retrying failed request (503): ${pRequest.runtimeType}"),
          maxAttempts: 3,
          maxDelay: Duration(seconds: ConfigService().getAppConfig()!.requestTimeout!),
        );

        if (response.statusCode >= 400 && response.statusCode <= 599) {
          var body = await _decodeBody(response);
          FlutterUI.logAPI.e("Server sent HTTP ${response.statusCode}: $body");
          if (response.statusCode == 404) {
            throw Exception("Application not found (404)");
          } else if (response.statusCode == 410) {
            throw SessionExpiredException(response.statusCode);
          } else if (response.statusCode == 500) {
            throw Exception("General Server Error (500)");
          } else {
            throw Exception("Request Error (${response.statusCode}):\n$body");
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
                () => _sendPostRequest(route, pRequest),
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
      } catch (e) {
        FlutterUI.logAPI.e("Error while sending ${pRequest.runtimeType}");
        rethrow;
      }
    } else {
      throw Exception("URI belonging to ${pRequest.runtimeType} not found, add it to the apiConfig!");
    }
  }

  Future<String> _decodeBody(HttpClientResponse response) {
    return response.transform(utf8.decoder).join();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Send post request to remote server, applies timeout.
  Future<HttpClientResponse> _sendPostRequest(APIRoute route, ApiRequest pRequest) async {
    Uri uri = Uri.parse("${ConfigService().getBaseUrl()!}/${route.route}");
    HttpClientRequest request = await connect(uri, route.method);

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

  Future<HttpClientRequest> connect(Uri pUri, Method method) {
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
