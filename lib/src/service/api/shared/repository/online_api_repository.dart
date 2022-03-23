import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/api_response_names.dart';
import 'package:flutter_client/src/model/api/requests/api_request.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';
import 'package:flutter_client/src/model/api/response/application_meta_data_response.dart';
import 'package:flutter_client/src/model/api/response/application_parameter_response.dart';
import 'package:flutter_client/src/model/api/response/close_screen_response.dart';
import 'package:flutter_client/src/model/api/response/dal_fetch_response.dart';
import 'package:flutter_client/src/model/api/response/dal_meta_data_response.dart';
import 'package:flutter_client/src/model/api/response/menu_response.dart';
import 'package:flutter_client/src/model/api/response/screen_generic_response.dart';
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
  ApiResponseNames.applicationMetaData :
      ({required Map<String, dynamic> pJson}) => ApplicationMetaDataResponse.fromJson(pJson),
  ApiResponseNames.applicationParameters :
      ({required Map<String, dynamic> pJson}) => ApplicationParametersResponse.fromJson(pJson),
  ApiResponseNames.closeScreen :
      ({required Map<String, dynamic> pJson}) => CloseScreenResponse.fromJson(json: pJson),
  ApiResponseNames.dalFetch :
      ({required Map<String, dynamic> pJson}) => DalFetchResponse.fromJson(pJson),
  ApiResponseNames.menu :
      ({required Map<String, dynamic> pJson}) => MenuResponse.fromJson(pJson),
  ApiResponseNames.screenGeneric :
      ({required Map<String, dynamic> pJson}) => ScreenGenericResponse.fromJson(pJson),
  ApiResponseNames.dalMetaData :
      ({required Map<String, dynamic> pJson}) => DalMetaDataResponse.fromJson(pJson: pJson)
  };

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Api config for remote endpoints and url
  final ApiConfig apiConfig;
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
  Future<List<ApiResponse>> sendRequest({required ApiRequest pRequest}) async {
    Uri? uri = apiConfig.uriMap[pRequest.runtimeType];

    if(uri != null) {
      var response = _sendPostRequest(uri, jsonEncode(pRequest));
      return response
          .then((response) => response.body)
          .then((body) => jsonDecode(body) as List<dynamic>)
          .then((jsonResponses) => _responseParser(pJsonList: jsonResponses));
    } else {
      throw Exception("URI belonging to ${pRequest.runtimeType} not found, add it to the apiConfig!");
    }


  }

  List<Map<String, dynamic>> _test(String a) {


    int a = 2+4;
    return a as List<Map<String, dynamic>>;
  }

  @override
  Future<Uint8List> downloadImages({required ApiDownloadImagesRequest pRequest}) {
    Uri? uri = apiConfig.uriMap[pRequest.runtimeType];

    if(uri != null) {
      var response = _sendPostRequest(uri, jsonEncode(pRequest));
      return response
          .then((response) => response.bodyBytes);
    } else {
      throw Exception("URI belonging to ${pRequest.runtimeType} not found, add it to the apiConfig!");
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Future<Response> _sendPostRequest(Uri uri, String body) {
    _headers["Access-Control_Allow_Origin"] = "*";
    HttpHeaders.contentTypeHeader;
    Future<Response> res = client.post(uri, headers: _headers, body: body);
    res.then(_extractCookie);
    return res;
  }

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


    for(dynamic responseItem in pJsonList) {
      ResponseFactory? builder = responseFactoryMap[responseItem[ApiObjectProperty.name]];

      if(builder != null) {
        returnList.add(builder(pJson: responseItem));
      } else {
        // throw Exception("Builder for response ${responseItem[ApiObjectProperty.name]} from json in online repository not found");
      }
    }

    return returnList;
  }





}
