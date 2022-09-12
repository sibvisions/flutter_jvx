import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:universal_io/io.dart';

import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../mixin/ui_service_mixin.dart';
import '../../../../../util/extensions/list_extensions.dart';
import '../../../../../util/logging/flutter_logger.dart';
import '../../../../model/config/api/api_config.dart';
import '../../../../model/request/api_download_images_request.dart';
import '../../../../model/request/api_download_style_request.dart';
import '../../../../model/request/api_download_translation_request.dart';
import '../../../../model/request/api_upload_request.dart';
import '../../../../model/request/i_api_download_request.dart';
import '../../../../model/request/i_api_request.dart';
import '../../../../model/request/i_session_request.dart';
import '../../../../model/response/api_response.dart';
import '../../../../model/response/application_meta_data_response.dart';
import '../../../../model/response/application_parameter_response.dart';
import '../../../../model/response/authentication_data_response.dart';
import '../../../../model/response/close_screen_response.dart';
import '../../../../model/response/dal_data_provider_changed_response.dart';
import '../../../../model/response/dal_fetch_response.dart';
import '../../../../model/response/dal_meta_data_response.dart';
import '../../../../model/response/download_images_response.dart';
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

typedef ResponseFactory = ApiResponse Function({required Map<String, dynamic> pJson, required Object originalRequest});

/// Handles all possible requests to the mobile server.
class OnlineApiRepository with ConfigServiceGetterMixin, UiServiceGetterMixin implements IRepository {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static Map<String, ResponseFactory> maps = {
    ApiResponseNames.applicationMetaData: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        ApplicationMetaDataResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.applicationParameters: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        ApplicationParametersResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.closeScreen: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        CloseScreenResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.dalFetch: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        DalFetchResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.menu: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        MenuViewResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.screenGeneric: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        GenericScreenViewResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.dalMetaData: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        DalMetaDataResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.userData: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        UserDataResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.login: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        LoginViewResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.error: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        ErrorViewResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.sessionExpired: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        SessionExpiredResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.dalDataProviderChanged: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        DalDataProviderChangedResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.authenticationData: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        AuthenticationDataResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.messageDialog: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        MessageDialogResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.upload: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        UploadActionResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
  };

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Api config for remote endpoints and url
  ApiConfig? apiConfig;

  /// Http client for outside connection
  HttpClient? client;

  /// Header fields, used for sessionId
  final Map<String, String> _headers = {"Access-Control_Allow_Origin": "*"};

  /// Cookies used for sessionId
  final Set<Cookie> _cookies = {};

  /// Maps response names with a corresponding factory
  late final Map<String, ResponseFactory> responseFactoryMap = Map.from(maps);

  static const String boundary = "--dart-http-boundary--";

  /// A regular expression that matches strings that are composed entirely of
  /// ASCII-compatible characters.
  final _asciiOnly = RegExp(r'^[\x00-\x7F]+$');

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OnlineApiRepository({
    this.apiConfig,
  });

  @override
  Future<void> start() async {
    if (isStopped()) {
      client = HttpClient()..connectionTimeout = Duration(seconds: getConfigService().getAppConfig()!.requestTimeout!);
    }
  }

  @override
  Future<void> stop() async {
    client?.close();
    client = null;
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
    if (apiConfig == null) throw Exception("ApiConfig not initialized");

    Uri? uri = apiConfig!.uriMap[pRequest.runtimeType]?.call();

    if (uri != null) {
      try {
        if (pRequest is ISessionRequest) {
          if (getConfigService().getClientId()?.isNotEmpty == true) {
            pRequest.clientId = getConfigService().getClientId()!;
          } else {
            throw Exception("No Client ID found while trying to send ${pRequest.runtimeType}");
          }
        }

        HttpClientResponse response = await _sendPostRequest(uri, pRequest);

        if (response.statusCode >= 400 && response.statusCode <= 599) {
          var body = await _decodeBody(response);
          LOGGER.logE(pType: LogType.COMMAND, pMessage: "Server sent HTTP ${response.statusCode}: $body");
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

        if (getUiService().getAppManager() != null) {
          var overrideResponse = await getUiService().getAppManager()?.handleResponse(
                pRequest,
                responseBody,
                () => _sendPostRequest(uri, pRequest),
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

        getUiService().getAppManager()?.modifyResponses(parsedResponseObjects, pRequest);

        if (getConfigService().isOffline()) {
          var viewResponse = parsedResponseObjects.firstWhereOrNull((element) => element is MessageView);
          if (viewResponse != null) {
            var messageViewResponse = viewResponse as MessageView;
            throw StateError("Server sent error: $messageViewResponse");
          }
        }

        return parsedResponseObjects;
      } catch (e) {
        LOGGER.logE(pType: LogType.COMMAND, pMessage: "Error while sending ${pRequest.runtimeType}");
        rethrow;
      }
    } else {
      throw Exception("URI belonging to ${pRequest.runtimeType} not found, add it to the apiConfig!");
    }
  }

  Future<String> _decodeBody(HttpClientResponse response) {
    return response.transform(utf8.decoder).join();
  }

  @override
  void setApiConfig({required ApiConfig config}) {
    apiConfig = config;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Send post request to remote server, applies timeout.
  Future<HttpClientResponse> _sendPostRequest(Uri uri, IApiRequest pRequest) async {
    HttpClientRequest request = await client!.postUrl(uri);

    if (kIsWeb) {
      if (request is BrowserHttpClientRequest) {
        //Handles cookies in browser
        request.browserCredentialsMode = true;
      }
    } else {
      _cookies.forEach((value) => request.cookies.add(value));
    }

    getUiService().getAppManager()?.modifyCookies(request.cookies);

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
    } else {
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
    }

    return parsedResponse;
  }
}
