import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:universal_io/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../../config/api/api_route.dart';
import '../../../../../flutter_jvx.dart';
import '../../../../../services.dart';
import '../../../../model/command/api/changes_command.dart';
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
import '../../../../model/request/api_insert_record_request.dart';
import '../../../../model/request/api_login_request.dart';
import '../../../../model/request/api_logout_request.dart';
import '../../../../model/request/api_navigation_request.dart';
import '../../../../model/request/api_open_screen_request.dart';
import '../../../../model/request/api_open_tab_request.dart';
import '../../../../model/request/api_press_button_request.dart';
import '../../../../model/request/api_reload_menu_request.dart';
import '../../../../model/request/api_reset_password_request.dart';
import '../../../../model/request/api_select_record_request.dart';
import '../../../../model/request/api_set_value_request.dart';
import '../../../../model/request/api_set_values_request.dart';
import '../../../../model/request/api_startup_request.dart';
import '../../../../model/request/api_upload_request.dart';
import '../../../../model/request/i_api_download_request.dart';
import '../../../../model/request/i_api_request.dart';
import '../../../../model/request/i_session_request.dart';
import '../../../../model/response/api_response.dart';
import '../../../../model/response/application_meta_data_response.dart';
import '../../../../model/response/application_parameter_response.dart';
import '../../../../model/response/application_settings_response.dart';
import '../../../../model/response/authentication_data_response.dart';
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
import '../../../../model/response/login_view_response.dart';
import '../../../../model/response/menu_view_response.dart';
import '../../../../model/response/upload_action_response.dart';
import '../../../../model/response/user_data_response.dart';
import '../../../../model/response/view/message/error_view_response.dart';
import '../../../../model/response/view/message/message_dialog_response.dart';
import '../../../../model/response/view/message/message_view.dart';
import '../../../../model/response/view/message/session_expired_response.dart';
import '../api_object_property.dart';
import '../api_response_names.dart';
import '../i_repository.dart';
import 'web_socket/universal_web_socket.dart';

typedef ResponseFactory = ApiResponse Function({required Map<String, dynamic> pJson, required Object originalRequest});

/// Handles all possible requests to the mobile server.
class OnlineApiRepository implements IRepository {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all remote request mapped to their route
  static final Map<Type, APIRoute Function(IApiRequest pRequest)> uriMap = {
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
  };

  static final Map<String, ResponseFactory> maps = {
    ApiResponseNames.applicationMetaData: ApplicationMetaDataResponse.fromJson,
    ApiResponseNames.applicationParameters: ApplicationParametersResponse.fromJson,
    ApiResponseNames.applicationSettings: ApplicationSettingsResponse.fromJson,
    ApiResponseNames.closeScreen: CloseScreenResponse.fromJson,
    ApiResponseNames.closeFrame: CloseFrameResponse.fromJson,
    ApiResponseNames.dalFetch: DalFetchResponse.fromJson,
    ApiResponseNames.menu: MenuViewResponse.fromJson,
    ApiResponseNames.screenGeneric: GenericScreenViewResponse.fromJson,
    ApiResponseNames.dalMetaData: DalMetaDataResponse.fromJson,
    ApiResponseNames.userData: UserDataResponse.fromJson,
    ApiResponseNames.login: LoginViewResponse.fromJson,
    ApiResponseNames.error: ErrorViewResponse.fromJson,
    ApiResponseNames.sessionExpired: SessionExpiredResponse.fromJson,
    ApiResponseNames.dalDataProviderChanged: DalDataProviderChangedResponse.fromJson,
    ApiResponseNames.authenticationData: AuthenticationDataResponse.fromJson,
    ApiResponseNames.messageDialog: MessageDialogResponse.fromJson,
    ApiResponseNames.deviceStatus: DeviceStatusResponse.fromJson,
    ApiResponseNames.upload: UploadActionResponse.fromJson,
    ApiResponseNames.download: DownloadActionResponse.fromJson,
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
    client ??= HttpClient()..connectionTimeout = Duration(seconds: IConfigService().getAppConfig()!.requestTimeout!);
  }

  Future<void> startWebSocket([bool reconnect = false]) async {
    await stopWebSocket();

    if (reconnect && isStopped()) {
      return;
    }

    var uri = _getWebSocketUri(reconnect);
    try {
      FlutterJVx.log.i("Connecting to Websocket on $uri");

      webSocket = UniversalWebSocketChannel.create(
        uri,
        {"Cookie": _cookies.map((e) => "${e.name}=${e.value}").join(";")},
      );

      webSocket!.stream.listen(
        (data) {
          lastDelay = 2;
          manualClose = false;
          if (data.isNotEmpty) {
            try {
              FlutterJVx.log.i("Received data via websocket: $data");
              if (data == "api/changes") {
                ICommandService().sendCommand(ChangesCommand(reason: "Server sent api/changes"));
              }
            } catch (e) {
              FlutterJVx.log.e("Error handling websocket message:", e);
            }
          }
        },
        onError: (error) {
          FlutterJVx.log.w("Connection to Websocket failed", error);

          //Cancel reconnect if manually closed
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
          FlutterJVx.log.w(
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
      FlutterJVx.log.e("Connection to Websocket could not be established!", e);
      rethrow;
    }
  }

  void showStatus(String message) {
    if (!IConfigService().isOffline()) {
      ScaffoldMessenger.of(FlutterJVx.getCurrentContext()!).showSnackBar(SnackBar(
        content: Text(message),
      ));
    }
  }

  void reconnectWebSocket() {
    lastDelay = min(lastDelay << 1, 120);
    FlutterJVx.log.i("Retrying Websocket connection in $lastDelay seconds...");
    Timer(Duration(seconds: lastDelay), () {
      FlutterJVx.log.i("Retrying Websocket connection");
      startWebSocket(true);
    });
  }

  Uri _getWebSocketUri(bool reconnect) {
    Uri location = Uri.parse(IConfigService().getBaseUrl()!);

    const String subPath = "/services/mobile";
    int? end = location.path.lastIndexOf(subPath);
    if (end == -1) end = null;

    return location.replace(
      scheme: location.scheme == "https" ? "wss" : "ws",
      path: "${location.path.substring(0, end)}/pushlistener",
      queryParameters: {
        "clientId": IConfigService().getClientId()!,
        if (reconnect) "reconnect": null,
      },
    );
  }

  Future<void> stopWebSocket() async {
    manualClose = true;
    await webSocket?.sink.close(status.normalClosure);
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
  Future<List<ApiResponse>> sendRequest({required IApiRequest pRequest}) async {
    if (isStopped()) throw Exception("Repository not initialized");

    APIRoute? route = uriMap[pRequest.runtimeType]?.call(pRequest);

    if (route != null) {
      try {
        if (pRequest is ISessionRequest) {
          if (IConfigService().getClientId()?.isNotEmpty == true) {
            pRequest.clientId = IConfigService().getClientId()!;
          } else {
            throw Exception("No Client ID found while trying to send ${pRequest.runtimeType}");
          }
        }

        HttpClientResponse response = await _sendPostRequest(route, pRequest);

        if (response.statusCode >= 400 && response.statusCode <= 599) {
          var body = await _decodeBody(response);
          FlutterJVx.log.e("Server sent HTTP ${response.statusCode}: $body");
          if (response.statusCode == 404) {
            throw Exception("Application not found (404)");
          } else if (response.statusCode == 500) {
            throw Exception("General Server Error (500)");
          } else {
            throw Exception("Request Error (${response.statusCode}):\n$body");
          }
        }

        // Download Request needs different handling
        if (pRequest is IApiDownloadRequest) {
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

        if (response.headers.contentType?.value != ContentType.json.value) {
          throw FormatException("Invalid server response"
              "\nType: ${response.headers.contentType?.subType}"
              "\nStatus: ${response.statusCode}");
        }

        List<dynamic> jsonResponse = _parseAndCheckJson(responseBody);
        List<ApiResponse> parsedResponseObjects = _responseParser(pJsonList: jsonResponse, originalRequest: pRequest);

        IUiService().getAppManager()?.modifyResponses(parsedResponseObjects, pRequest);

        if (IConfigService().isOffline()) {
          var viewResponse = parsedResponseObjects.firstWhereOrNull((element) => element is MessageView);
          if (viewResponse != null) {
            var messageViewResponse = viewResponse as MessageView;
            throw StateError("Server sent error: $messageViewResponse");
          }
        }

        return parsedResponseObjects;
      } catch (e) {
        FlutterJVx.log.e("Error while sending ${pRequest.runtimeType}");
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
  Future<HttpClientResponse> _sendPostRequest(APIRoute route, IApiRequest pRequest) async {
    Uri uri = Uri.parse("${IConfigService().getBaseUrl()!}/${route.route}");
    HttpClientRequest request = await connect(uri, route.method);

    if (kIsWeb) {
      if (request is BrowserHttpClientRequest) {
        //Handles cookies in browser
        request.browserCredentialsMode = true;
      }
    } else {
      _cookies.forEach((value) => request.cookies.add(value));
    }

    IUiService().getAppManager()?.modifyCookies(request.cookies);

    _headers.forEach((key, value) => request.headers.set(key, value));

    if (pRequest is ApiUploadRequest) {
      request.headers.contentType = ContentType(
        "multipart",
        "form-data",
        charset: "utf-8",
        parameters: {"boundary": boundary},
      );
      await request.addStream(_addContent(
        {
          "clientId": pRequest.clientId,
          "fileId": pRequest.fileId,
        },
        {"data": pRequest.file},
        boundary,
      ));
    } else if (route.method != Method.GET) {
      request.headers.contentType = ContentType("application", "json", charset: "utf-8");
      request.write(jsonEncode(pRequest));
    }

    HttpClientResponse res = await request.close();

    if (!kIsWeb) {
      //Extract the session-id cookie to be sent in future
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

  Stream<List<int>> _addContent(Map<String, String> fields, Map<String, File> files, String boundary) async* {
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
      yield* Stream.fromIterable([file.value.readAsBytesSync()]);
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
  List<ApiResponse> _responseParser({required List<dynamic> pJsonList, required Object originalRequest}) {
    List<ApiResponse> returnList = [];

    for (dynamic responseItem in pJsonList) {
      ResponseFactory? builder = responseFactoryMap[responseItem[ApiObjectProperty.name]];

      if (builder != null) {
        returnList.add(builder(pJson: responseItem, originalRequest: originalRequest));
      } else {
        // returnList.add(ErrorResponse(message: "Could not find builder for ${responseItem[ApiObjectProperty.name]}", name: ApiResponseNames.error));
      }
    }

    return returnList;
  }

  List<ApiResponse> _handleDownload({required Uint8List pBody, required IApiDownloadRequest pRequest}) {
    List<ApiResponse> parsedResponse = [];

    if (pRequest is ApiDownloadImagesRequest) {
      parsedResponse.add(DownloadImagesResponse(
        responseBody: pBody,
        name: ApiResponseNames.downloadImages,
        originalRequest: pRequest,
      ));
    } else if (pRequest is ApiDownloadTranslationRequest) {
      parsedResponse.add(DownloadTranslationResponse(
        bodyBytes: pBody,
        name: ApiResponseNames.downloadTranslation,
        originalRequest: pRequest,
      ));
    } else if (pRequest is ApiDownloadStyleRequest) {
      parsedResponse.add(DownloadStyleResponse(
        bodyBytes: pBody,
        name: ApiResponseNames.downloadStyle,
        originalRequest: pRequest,
      ));
    } else if (pRequest is ApiDownloadRequest) {
      parsedResponse.add(DownloadResponse(
        bodyBytes: pBody,
        name: ApiResponseNames.downloadResponse,
        originalRequest: pRequest,
      ));
    }

    return parsedResponse;
  }
}
