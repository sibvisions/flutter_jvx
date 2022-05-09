import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/api_response_names.dart';
import 'package:flutter_client/src/model/api/requests/i_api_request.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';
import 'package:flutter_client/src/model/api/response/application_meta_data_response.dart';
import 'package:flutter_client/src/model/api/response/application_parameter_response.dart';
import 'package:flutter_client/src/model/api/response/close_screen_response.dart';
import 'package:flutter_client/src/model/api/response/dal_data_provider_changed_response.dart';
import 'package:flutter_client/src/model/api/response/dal_fetch_response.dart';
import 'package:flutter_client/src/model/api/response/dal_meta_data_response.dart';
import 'package:flutter_client/src/model/api/response/error_response.dart';
import 'package:flutter_client/src/model/api/response/login_response.dart';
import 'package:flutter_client/src/model/api/response/menu_response.dart';
import 'package:flutter_client/src/model/api/response/screen_generic_response.dart';
import 'package:flutter_client/src/model/api/response/session_expired_response.dart';
import 'package:flutter_client/src/model/api/response/user_data_response.dart';
import 'package:http/http.dart';

import '../../../../model/api/requests/api_download_images_request.dart';
import '../../../../model/config/api/api_config.dart';
import '../i_repository.dart';

typedef ResponseFactory = ApiResponse Function({required Map<String, dynamic> pJson});

/// Handles all possible requests to the mobile server.
class OnlineApiRepository implements IRepository {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static Map<String, ResponseFactory> maps = {
    ApiResponseNames.applicationMetaData: ({required Map<String, dynamic> pJson}) =>
        ApplicationMetaDataResponse.fromJson(pJson),
    ApiResponseNames.applicationParameters: ({required Map<String, dynamic> pJson}) =>
        ApplicationParametersResponse.fromJson(pJson),
    ApiResponseNames.closeScreen: ({required Map<String, dynamic> pJson}) => CloseScreenResponse.fromJson(json: pJson),
    ApiResponseNames.dalFetch: ({required Map<String, dynamic> pJson}) => DalFetchResponse.fromJson(pJson),
    ApiResponseNames.menu: ({required Map<String, dynamic> pJson}) => MenuResponse.fromJson(pJson),
    ApiResponseNames.screenGeneric: ({required Map<String, dynamic> pJson}) => ScreenGenericResponse.fromJson(pJson),
    ApiResponseNames.dalMetaData: ({required Map<String, dynamic> pJson}) => DalMetaDataResponse.fromJson(pJson: pJson),
    ApiResponseNames.userData: ({required Map<String, dynamic> pJson}) => UserDataResponse.fromJson(json: pJson),
    ApiResponseNames.login: ({required Map<String, dynamic> pJson}) => LoginResponse.fromJson(pJson: pJson),
    ApiResponseNames.error: ({required Map<String, dynamic> pJson}) => ErrorResponse.fromJson(pJson: pJson),
    ApiResponseNames.sessionExpired: ({required Map<String, dynamic> pJson}) =>
        SessionExpiredResponse.fromJson(pJson: pJson),
    ApiResponseNames.dalDataProviderChanged: ({required Map<String, dynamic> pJson}) =>
        DalDataProviderChangedResponse.fromJson(pJson: pJson),
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
    Uri? uri = apiConfig.uriMap[pRequest.runtimeType];

    if (uri != null) {
      var response = _sendPostRequest(uri, jsonEncode(pRequest));
      return response
          .then((response) => response.body)
          .then(_caseResponses)
          .then((jsonResponses) => _responseParser(pJsonList: jsonResponses))
          .onError((error, stackTrace) => [
                ErrorResponse(
                    message: "Message timed out", name: ApiResponseNames.error, error: error, stacktrace: stackTrace)
              ]);
    } else {
      throw Exception("URI belonging to ${pRequest.runtimeType} not found, add it to the apiConfig!");
    }
  }

  @override
  Future<Uint8List> downloadImages({required ApiDownloadImagesRequest pRequest}) {
    Uri? uri = apiConfig.uriMap[pRequest.runtimeType];

    if (uri != null) {
      var response = _sendPostRequest(uri, jsonEncode(pRequest));
      return response.then((response) => response.bodyBytes);
    } else {
      throw Exception("URI belonging to ${pRequest.runtimeType} not found, add it to the apiConfig!");
    }
  }

  @override
  void setApiConfig({required ApiConfig config}) {
    apiConfig = config;
    apiConfig.updateUriMap();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Send post request to remote server, applies timeout.
  Future<Response> _sendPostRequest(Uri uri, String body) async {
    _headers["Access-Control_Allow_Origin"] = "*";
    HttpHeaders.contentTypeHeader;
    Future<Response> res = client.post(uri, headers: _headers, body: body);
    res.then(_extractCookie);
    return res.timeout(const Duration(seconds: 10));
  }

  /// Check if response is an error, an error does not come as array, returns
  /// the error in an error.
  Future<List<dynamic>> _caseResponses(String pBody) async {
    var response = jsonDecode(pBody);

    if (response is List<dynamic>) {
      return response;
    } else {
      return [response];
    }
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

  List<ApiResponse> _responseParser({required List<dynamic> pJsonList}) {
    List<ApiResponse> returnList = [];

    for (dynamic responseItem in pJsonList) {
      ResponseFactory? builder = responseFactoryMap[responseItem[ApiObjectProperty.name]];

      if (builder != null) {
        returnList.add(builder(pJson: responseItem));
      } else {
        // returnList.add(ErrorResponse(message: "Could not find builder for ${responseItem[ApiObjectProperty.name]}", name: ApiResponseNames.error));
      }
    }

    return returnList;
  }
}
