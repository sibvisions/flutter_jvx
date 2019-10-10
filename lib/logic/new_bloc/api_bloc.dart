import 'dart:io';

import 'package:archive/archive.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/action.dart' as prefix0;
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/model/application_meta_data.dart';
import 'package:jvx_mobile_v3/model/application_style/application_style.dart';
import 'package:jvx_mobile_v3/model/auth_data.dart';
import 'package:jvx_mobile_v3/model/close_screen/close_screen.dart';
import 'package:jvx_mobile_v3/model/download/download.dart';
import 'package:jvx_mobile_v3/model/login/login.dart';
import 'package:jvx_mobile_v3/model/logout/logout.dart';
import 'package:jvx_mobile_v3/model/open_screen/open_screen.dart';
import 'package:jvx_mobile_v3/model/screen_generic.dart';
import 'package:jvx_mobile_v3/model/startup/startup.dart';
import 'package:jvx_mobile_v3/services/new_rest_client.dart';
import 'package:jvx_mobile_v3/utils/shared_preferences_helper.dart';

import 'package:jvx_mobile_v3/utils/globals.dart' as globals;
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:path_provider/path_provider.dart';

class ApiBloc extends Bloc<Request, Response> {
  @override
  Response get initialState => Response()..loading = true;

  @override
  Stream<Response> mapEventToState(Request event) async* {
    if (event is Startup) {
      yield* startup(event);
    } else if (event is Login) {
      yield* login(event);
    } else if (event is Logout) {
      yield* logout(event);
    } else if (event is OpenScreen) {
      yield* openscreen(event);
    } else if (event is CloseScreen) {
      yield* closescreen(event);
    } else if (event is Download) {
      yield* download(event);
    } else if (event is ApplicationStyle) {
      yield* applicationStyle(event);
    }
  }

  Stream<Response> startup(Startup request) async* {
    Map<String, String> authData =
        await SharedPreferencesHelper().getLoginData();

    globals.username = authData['username'];

    if (authData['authKey'] != null) {
      request.authKey = authData['authKey'];
    }

    Response resp = await processRequest(request);

    if (!resp.error) {
      if (resp != null &&
          resp.applicationMetaData != null) {
        ApplicationMetaData applicationMetaData = resp.applicationMetaData;
        if (applicationMetaData != null) {
          globals.clientId = applicationMetaData.clientId;
          globals.language = applicationMetaData.langCode;
          globals.appVersion = applicationMetaData.version;
          Translations.load(Locale(globals.language));
        }
      }
    }

    yield resp;
  }

  Stream<Response> login(Login request) async* {
    globals.username = request.username;
    SharedPreferencesHelper().setLoginData(request.username, request.password);

    Response resp = await processRequest(request);

    AuthenticationData authData;
    if (resp.authenticationData != null)
      authData = resp.authenticationData;

    if (authData != null)
      SharedPreferencesHelper().setAuthKey(authData.authKey);

    yield resp;
  }

  Stream<Response> logout(Logout request) async* {
    yield await processRequest(request);
  }

  Stream<Response> openscreen(OpenScreen request) async* {
    prefix0.Action action = request.action;

    Response resp = await processRequest(request);

    if (!resp.error)
      resp.action = action;

    yield resp;
  }

  Stream<Response> closescreen(CloseScreen request) async* {
    Response resp = await processRequest(request);
    
    yield resp;
  }

  Stream<Response> download(Download request) async* {
    Response resp = await processRequest(request);

    var _dir = (await getApplicationDocumentsDirectory()).path;

    globals.dir = _dir;

    if (request.requestType == RequestType.DOWNLOAD_TRANSLATION) {
      var archive = resp.download;

      globals.translation = <String, String>{};

      for (var file in archive) {
        var filename = '$_dir/${file.name}';
        if (file.isFile) {
          var outFile = File(filename);
          globals.translation[file.name] = filename;
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
        }
      }
      SharedPreferencesHelper().setTranslation(globals.translation);
      Translations.load(Locale(globals.language));
    } else if (request.requestType == RequestType.DOWNLOAD_IMAGES) {
      var archive = resp.download;

      globals.images = List<String>();

      for (var file in archive) {
        var filename = '${globals.dir}/${file.name}';
        if (file.isFile) {
          var outFile = File(filename);
          globals.images.add(filename);
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
        }
      }
    }

    yield resp;
  }

  Stream<Response> applicationStyle(ApplicationStyle request) async* {
    globals.dir = (await getApplicationDocumentsDirectory()).path;

    yield await processRequest(request);
  }

  Future<Response> processRequest(Request request) async {
    RestClient restClient = RestClient();
    Response response;

    switch (request.requestType) {
      case RequestType.STARTUP:
        response = await restClient.postAsync('/api/startup', request.toJson());
        response.requestType = request.requestType;
        updateResponse(response);
        return response;
        break;
      case RequestType.LOGIN:
        response = await restClient.postAsync('/api/login', request.toJson());
        response.requestType = request.requestType;
        updateResponse(response);
        return response;
        break;
      case RequestType.LOGOUT:
        response = await restClient.postAsync('/api/logout', request.toJson());
        response.requestType = request.requestType;
        updateResponse(response);
        return response;
        break;
      case RequestType.OPEN_SCREEN:
        response =
            await restClient.postAsync('/api/openScreen', request.toJson());
        response.requestType = request.requestType;
        updateResponse(response);
        return response;
        break;
      case RequestType.CLOSE_SCREEN:
        response =
            await restClient.postAsync('/api/closeScreen', request.toJson());
        response.requestType = request.requestType;
        updateResponse(response);
        return response;
        break;
      case RequestType.DAL_SELECT_RECORD:
        response = await restClient.postAsync(
            '/api/dal/selectRecord', request.toJson());
        response.requestType = request.requestType;
        updateResponse(response);
        return response;
        break;
      case RequestType.DAL_SET_VALUE:
        response =
            await restClient.postAsync('/api/dal/setValue', request.toJson());
        response.requestType = request.requestType;
        updateResponse(response);
        return response;
        break;
      case RequestType.DAL_FETCH:
        response =
            await restClient.postAsync('/api/dal/fetch', request.toJson());
        response.requestType = request.requestType;
        updateResponse(response);
        return response;
        break;
      case RequestType.DOWNLOAD_TRANSLATION:
        response =
            await restClient.postAsyncDownload('/download', request.toJson());
        response.requestType = request.requestType;
        response.download = ZipDecoder().decodeBytes(response.download);
        updateResponse(response);
        return response;
        break;
      case RequestType.DOWNLOAD_IMAGES:
        response =
            await restClient.postAsyncDownload('/download', request.toJson());
        response.requestType = request.requestType;
        response.download = ZipDecoder().decodeBytes(response.download);
        updateResponse(response);
        return response;
        break;
      case RequestType.APP_STYLE:
        response =
            await restClient.postAsync('/download', request.toJson());
        response.requestType = request.requestType;
        updateResponse(response);
        return response;
        break;
      case RequestType.PRESS_BUTTON:
        // TODO: Handle this case.
        break;
    }

    return null;
  }

  Response updateResponse(Response response) {
    Response currentResponse = currentState;
    Response toUpdate = response;

    if (toUpdate.applicationMetaData == null)
      toUpdate.applicationMetaData = currentResponse.applicationMetaData;
    if (toUpdate.applicationStyle == null)
      toUpdate.applicationStyle = currentResponse.applicationStyle;
    if (toUpdate.authenticationData == null)
      toUpdate.authenticationData = currentResponse.authenticationData;
    if (toUpdate.language == null)
      toUpdate.language = currentResponse.language;
    if (toUpdate.jVxData == null)
      toUpdate.jVxData = currentResponse.jVxData;
    if (toUpdate.jVxMetaData == null)
      toUpdate.jVxMetaData = currentResponse.jVxMetaData;
    if (toUpdate.loginItem == null)
      toUpdate.loginItem = currentResponse.loginItem;
    if (toUpdate.menu == null)
      toUpdate.menu = currentResponse.menu;
    if (toUpdate.screenGeneric == null)
      toUpdate.screenGeneric = currentResponse.screenGeneric;

    return toUpdate;
  }
}
