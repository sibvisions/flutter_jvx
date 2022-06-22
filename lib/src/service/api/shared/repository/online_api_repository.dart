import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/api_response_names.dart';
import 'package:flutter_client/src/model/api/requests/api_download_images_request.dart';
import 'package:flutter_client/src/model/api/requests/api_download_translation_request.dart';
import 'package:flutter_client/src/model/api/requests/i_api_download_request.dart';
import 'package:flutter_client/src/model/api/requests/i_api_request.dart';
import 'package:flutter_client/src/model/api/response/api_authentication_data_response.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';
import 'package:flutter_client/src/model/api/response/application_meta_data_response.dart';
import 'package:flutter_client/src/model/api/response/application_parameter_response.dart';
import 'package:flutter_client/src/model/api/response/close_screen_response.dart';
import 'package:flutter_client/src/model/api/response/dal_data_provider_changed_response.dart';
import 'package:flutter_client/src/model/api/response/dal_fetch_response.dart';
import 'package:flutter_client/src/model/api/response/dal_meta_data_response.dart';
import 'package:flutter_client/src/model/api/response/downloadTranslationResponse.dart';
import 'package:flutter_client/src/model/api/response/download_images_response.dart';
import 'package:flutter_client/src/model/api/response/error_response.dart';
import 'package:flutter_client/src/model/api/response/login_response.dart';
import 'package:flutter_client/src/model/api/response/menu_response.dart';
import 'package:flutter_client/src/model/api/response/message_dialog_response.dart';
import 'package:flutter_client/src/model/api/response/screen_generic_response.dart';
import 'package:flutter_client/src/model/api/response/session_expired_response.dart';
import 'package:flutter_client/src/model/api/response/user_data_response.dart';
import 'package:http/http.dart';

import '../../../../model/config/api/api_config.dart';
import '../i_repository.dart';
import 'browser_client.dart' if (dart.library.html) 'package:http/browser_client.dart';

typedef ResponseFactory = ApiResponse Function({required Map<String, dynamic> pJson, required Object originalRequest});

/// Handles all possible requests to the mobile server.
class OnlineApiRepository implements IRepository {
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
        MenuResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.screenGeneric: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        ScreenGenericResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.dalMetaData: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        DalMetaDataResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.userData: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        UserDataResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.login: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        LoginResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.error: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        ErrorResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.sessionExpired: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        SessionExpiredResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.dalDataProviderChanged: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        DalDataProviderChangedResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.authenticationData: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        ApiAuthenticationDataResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
    ApiResponseNames.messageDialog: ({required Map<String, dynamic> pJson, required Object originalRequest}) =>
        MessageDialogResponse.fromJson(pJson: pJson, originalRequest: originalRequest),
  };

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Api config for remote endpoints and url
  ApiConfig apiConfig;

  /// Http client for outside connection
  final Client client = Client();

  /// Header fields, used for sessionId
  final Map<String, String> _headers = {};

  /// Maps response names with a corresponding factory
  late final Map<String, ResponseFactory> responseFactoryMap = Map.from(maps);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OnlineApiRepository({
    required this.apiConfig,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<ApiResponse>> sendRequest({required IApiRequest pRequest}) async {
    Uri? uri = apiConfig.uriMap[pRequest.runtimeType]?.call();

    if (uri != null) {
      var response = _sendPostRequest(uri, jsonEncode(pRequest));

      if (pRequest is IApiDownloadRequest) {
        return response
            .then((response) => response.bodyBytes)
            .then((responseBody) => _handleDownload(pBody: responseBody, pRequest: pRequest));
      } else {
        return response
            .then((response) => response.body)
            .then(_checkResponse)
            .then((jsonResponses) => _responseParser(pJsonList: jsonResponses, originalRequest: pRequest))
            .onError((error, stackTrace) => _handleError(error, stackTrace, pRequest));
      }
    } else {
      throw Exception("URI belonging to ${pRequest.runtimeType} not found, add it to the apiConfig!");
    }
  }

  @override
  void setApiConfig({required ApiConfig config}) {
    apiConfig = config;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Send post request to remote server, applies timeout.
  Future<Response> _sendPostRequest(Uri uri, String body) async {
    _headers["Access-Control_Allow_Origin"] = "*";
    if (kIsWeb) {
      if (client is BrowserClient) {
        (client as BrowserClient).withCredentials = true;
      }
    }
    Future<Response> res = client.post(uri, headers: _headers, body: body);
    if (!kIsWeb) {
      res.then(_extractCookie);
    }
    return res.timeout(const Duration(seconds: 10));
  }

  /// Extract the session-id cookie to be sent in future
  void _extractCookie(Response res) {
    String? rawCookie = res.headers["set-cookie"];

    if (rawCookie != null) {
      String cookie = rawCookie.substring(0, rawCookie.indexOf(";"));

      _headers.putIfAbsent("Cookie", () => cookie);
      if (_headers.containsKey("Cookie")) {
        _headers.update("Cookie", (value) => cookie);
      }
    }
  }

  /// Check if response is an error, an error does not come as array, returns
  /// the error in an error.
  Future<List<dynamic>> _checkResponse(String pBody) async {
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
      parsedResponse.add(DownloadImagesResponse(responseBody: pBody, name: "downloadImages", originalRequest: pRequest));
    } else if (pRequest is ApiDownloadTranslationRequest) {
      parsedResponse.add(DownloadTranslationResponse(bodyBytes: pBody, name: "downloadTranslation", originalRequest: pRequest));
    }

    return parsedResponse;
  }

  Future<List<ApiResponse>> _handleError(Object? error, StackTrace stackTrace, Object originalRequest) async {
    if (error is TimeoutException) {
      return [
        ErrorResponse(
            message: "Message timed out",
            name: ApiResponseNames.error,
            error: error,
            stacktrace: stackTrace,
            originalRequest: originalRequest)
      ];
    }
    return [
      ErrorResponse(
          message: "Repository error : $error}",
          name: ApiResponseNames.error,
          error: error,
          stacktrace: stackTrace,
          originalRequest: originalRequest)
    ];
  }
}
