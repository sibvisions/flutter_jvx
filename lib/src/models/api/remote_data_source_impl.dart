import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart';

import '../../services/remote/cubit/api_cubit.dart';
import '../../services/remote/rest/rest_client.dart';
import '../../ui/util/error/error_handler.dart';
import '../state/app_state.dart';
import 'data_source.dart';
import 'errors/failure.dart';
import 'request.dart';
import 'requests/application_style_request.dart';
import 'requests/change_request.dart';
import 'requests/close_screen_request.dart';
import 'requests/data/data_request.dart';
import 'requests/data/delete_record_request.dart';
import 'requests/data/fetch_data_request.dart';
import 'requests/data/filter_data_request.dart';
import 'requests/data/insert_record_request.dart';
import 'requests/data/meta_data_request.dart';
import 'requests/data/save_data_request.dart';
import 'requests/data/select_record_request.dart';
import 'requests/data/set_values_request.dart';
import 'requests/device_status_request.dart';
import 'requests/download_images_request.dart';
import 'requests/download_request.dart';
import 'requests/download_translation_request.dart';
import 'requests/login_request.dart';
import 'requests/logout_request.dart';
import 'requests/menu_request.dart';
import 'requests/navigation_request.dart';
import 'requests/open_screen_request.dart';
import 'requests/press_button_request.dart';
import 'requests/set_component_value.dart';
import 'requests/startup_request.dart';
import 'requests/tab_close_request.dart';
import 'requests/tab_select_request.dart';
import 'requests/upload_request.dart';
import 'response_objects/download_response_object.dart';
import 'response_objects/upload_response_object.dart';

class RemoteDataSourceImpl implements DataSource {
  final RestClient client;
  final AppState appState;
  final bool debugResponse = false;

  bool debugRequest = true;

  RemoteDataSourceImpl({required this.client, required this.appState});

  @override
  Future<ApiState> applicationStyle(ApplicationStyleRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/download';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    return either.fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> change(ChangeRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/changes';

    return (await _sendRequest(Uri.parse(path), request))
        .fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> closeScreen(CloseScreenRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/closeScreen';

    return (await _sendRequest(Uri.parse(path), request))
        .fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> deviceStatus(DeviceStatusRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/deviceStatus';

    return (await _sendRequest(Uri.parse(path), request))
        .fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> downloadImages(DownloadImagesRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/download';

    Either<ApiError, ApiResponse> either =
        await _sendDownloadRequest(Uri.parse(path), request);

    return either.fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> downloadTranslation(
      DownloadTranslationRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/download';

    Either<ApiError, ApiResponse> either =
        await _sendDownloadRequest(Uri.parse(path), request);

    return either.fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> login(LoginRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/v2/login';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    return either.fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> logout(LogoutRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/logout';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    return either.fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> menu(MenuRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/menu';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    return either.fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> navigation(NavigationRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/navigation';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    return either.fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> openScreen(OpenScreenRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/v2/openScreen';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    return either.fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> pressButton(PressButtonRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/v2/pressButton';

    bool isGoOfflineRequest =
        request.classNameEventSourceRef == "OfflineButton";

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request, isGoOfflineRequest);

    return either.fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> setComponentValue(SetComponentValueRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/comp/setValue';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    return either.fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> startup(StartupRequest request) async {
    if (client.headers == null) {
      client.headers = <String, String>{'Content-Type': 'application/json'};
    }

    if (!kIsWeb)
      client.headers!['cookie'] = appState.screenManager.onCookie('');

    final path = appState.serverConfig!.baseUrl + '/api/startup';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    return either.fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> tabClose(TabCloseRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/comp/closeTab';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    return either.fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> tabSelect(TabSelectRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/api/comp/selectTab';

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    return either.fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> upload(UploadRequest request) async {
    final path = appState.serverConfig!.baseUrl + '/upload';

    Either<ApiError, ApiResponse> either =
        await _sendUploadRequest(Uri.parse(path), request);

    return either.fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> download(request) async {
    final path = appState.serverConfig!.baseUrl + '/download';

    Either<ApiError, ApiResponse> either =
        await _sendDownloadRequest(Uri.parse(path), request);

    return either.fold((l) => l, (r) => r);
  }

  @override
  Future<ApiState> data(DataRequest request) async {
    String path = appState.serverConfig!.baseUrl;

    if (request is SetValuesRequest) {
      path += '/api/dal/setValues';
    } else if (request is InsertRecordRequest) {
      path += '/api/dal/insertRecord';
    } else if (request is FetchDataRequest) {
      path += '/api/dal/fetch';
    } else if (request is SaveDataRequest) {
      path += '/api/dal/save';
    } else if (request is FilterDataRequest) {
      path += '/api/dal/filter';
    } else if (request is DeleteRecordRequest) {
      path += '/api/dal/deleteRecord';
    } else if (request is MetaDataRequest) {
      path += '/api/dal/metaData';
    } else if (request is SelectRecordRequest) {
      path += '/api/dal/selectRecord';
    }

    Either<ApiError, ApiResponse> either =
        await _sendRequest(Uri.parse(path), request);

    return either.fold((l) => l, (r) => r);
  }

  Future<Either<ApiError, ApiResponse>> _sendRequest(Uri uri, Request request,
      [bool isGoOfflineRequest = false]) async {
    if (debugRequest) {
      log('REQUEST ${uri.path}: ${request.debugInfo}');
    }

    if (!kIsWeb) {
      client.headers!['cookie'] =
          appState.screenManager.onCookie(client.headers!['cookie']!);
    }

    Either<Failure, http.Response> either = await client.post(
        uri: uri,
        data: request.toJson(),
        timeout: isGoOfflineRequest
            ? appState.appConfig!.goOfflineRequestTimeout
            : appState.appConfig!.requestTimeout);

    return either.fold((l) => Left(ApiError(failures: [l])), (r) async {
      if (r.statusCode != 404) {
        List decodedBody = [];

        ApiState? response =
            await appState.screenManager.onResponse(request, r.body, () async {
          return (await _sendRequest(uri, request)).fold((l) => l, (r) => r);
        });

        if (response == null) {
          try {
            if (kReleaseMode && !kIsWeb)
              decodedBody = await compute(_getDecodedBody, r.body);
            else
              decodedBody = _getDecodedBody(r.body);
          } on FormatException {
            return Left(ApiError(failures: [
              ServerFailure(
                  name: 'message.error',
                  details: '',
                  message: 'Could not parse response',
                  title: 'Parsing error')
            ]));
          }

          List<Failure> failures = _getErrorsIfExists(decodedBody);

          if (!kReleaseMode && debugResponse) {
            log('RESPONSE ${uri.path}: $decodedBody');
          }

          if (failures.isNotEmpty) {
            return Left(ApiError(failures: failures));
          } else {
            final cookie = r.headers['set-cookie'];

            if (cookie != null && cookie.isNotEmpty) {
              final index = cookie.indexOf(';');

              if (client.headers == null) {
                client.headers = <String, String>{
                  'Content-Type': 'application/json'
                };
              }

              if (kIsWeb) {
                document.cookie =
                    (index == -1) ? cookie : cookie.substring(0, index);
              } else {
                client.headers!['cookie'] =
                    (index == -1) ? cookie : cookie.substring(0, index);
              }
            }

            ApiResponse internResponse =
                ApiResponse.fromJson(request, decodedBody);

            return Right(internResponse);
          }
        } else if (response is ApiResponse) {
          return Right(response);
        } else if (response is ApiError) {
          return Left(response);
        } else {
          return Left(ApiError(failures: [
            ServerFailure(
                name: 'message.error',
                message: 'Something went wrong',
                title: 'Error',
                details: '')
          ]));
        }
      } else {
        return Left(ApiError(failures: [
          Failure(
              details: '',
              message: 'Could not fetch url',
              name: ErrorHandler.serverError,
              title: 'Not found')
        ]));
      }
    });
  }

  Future<Either<ApiError, ApiResponse>> _sendDownloadRequest(
      Uri uri, Request request) async {
    Either<Failure, http.Response> either = await client.post(
        uri: uri,
        data: request.toJson(),
        timeout: appState.appConfig!.requestTimeout);

    return either.fold((l) => Left(ApiError(failures: [l])), (r) {
      ApiResponse response = ApiResponse(request: request, objects: []);

      response.addResponseObject(DownloadResponseObject(
          name: 'download',
          fileId: request is DownloadRequest ? request.fileId : '',
          translation: (request is DownloadTranslationRequest),
          bodyBytes: r.bodyBytes));

      return Right(response);
    });
  }

  Future<Either<ApiError, ApiResponse>> _sendUploadRequest(
      Uri uri, UploadRequest request) async {
    Either<Failure, http.Response> either =
        await client.upload(uri: uri, data: request.toJson());

    return either.fold((l) => Left(ApiError(failures: [l])), (r) {
      ApiResponse response = ApiResponse.fromJson(request, json.decode(r.body));

      response.addResponseObject(
          UploadResponseObject(name: 'upload', filename: request.fileId));

      return Right(response);
    });
  }

  List<Failure> _getErrorsIfExists(List<dynamic> responses) {
    List<Failure> failures = <Failure>[];

    if (responses.isNotEmpty) {
      for (final response in responses) {
        if (response['name'] == 'message.error' ||
            response['name'] == 'server.error' ||
            response['name'] == 'message.sessionexpired') {
          failures.add(ServerFailure.fromJson(response));
        }
      }
    }

    return failures;
  }
}

String utf8Convert(String text) {
  try {
    List<int> bytes = text.codeUnits;
    return utf8.decode(bytes);
  } catch (e) {
    print("Failed to decode string to utf-8!");
    return text;
  }
}

List<dynamic> _getDecodedBody(String jsonString) {
  String body = utf8Convert(jsonString);

  dynamic decodedBody = json.decode(body);

  if (decodedBody is List)
    return decodedBody;
  else
    return [decodedBody];
}
