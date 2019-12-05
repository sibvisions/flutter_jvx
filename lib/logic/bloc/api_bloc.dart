import 'dart:io';
import 'package:archive/archive.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/action.dart' as prefix0;
import 'package:jvx_mobile_v3/model/api/request/change.dart';
import 'package:jvx_mobile_v3/model/api/request/data/fetch_data.dart';
import 'package:jvx_mobile_v3/model/api/request/data/filter_data.dart';
import 'package:jvx_mobile_v3/model/api/request/data/insert_record.dart';
import 'package:jvx_mobile_v3/model/api/request/data/save_data.dart';
import 'package:jvx_mobile_v3/model/api/request/data/set_values.dart';
import 'package:jvx_mobile_v3/model/api/request/data/select_record.dart';
import 'package:jvx_mobile_v3/model/api/request/device_Status.dart';
import 'package:jvx_mobile_v3/model/api/request/loading.dart';
import 'package:jvx_mobile_v3/model/api/request/navigation.dart';
import 'package:jvx_mobile_v3/model/api/request/press_button.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/request/upload.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/model/api/response/application_meta_data.dart';
import 'package:jvx_mobile_v3/model/api/request/application_style.dart';
import 'package:jvx_mobile_v3/model/api/response/auth_data.dart';
import 'package:jvx_mobile_v3/model/api/request/close_screen.dart';
import 'package:jvx_mobile_v3/model/api/request/download.dart';
import 'package:jvx_mobile_v3/model/api/request/login.dart';
import 'package:jvx_mobile_v3/model/api/request/logout.dart';
import 'package:jvx_mobile_v3/model/api/request/open_screen.dart';
import 'package:jvx_mobile_v3/model/api/request/startup.dart';
import 'package:jvx_mobile_v3/services/rest_client.dart';
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
      yield updateResponse(Response()
        ..loading = true
        ..error = false
        ..requestType = RequestType.LOADING);
      yield* startup(event);
    } else if (event is Login) {
      yield updateResponse(Response()
        ..loading = true
        ..error = false
        ..requestType = RequestType.LOADING);
      yield* login(event);
    } else if (event is Logout) {
      yield updateResponse(Response()
        ..loading = true
        ..error = false
        ..requestType = RequestType.LOADING);
      yield* logout(event);
    } else if (event is OpenScreen) {
      yield updateResponse(Response()
        ..loading = true
        ..error = false
        ..requestType = RequestType.LOADING);
      yield* openscreen(event);
    } else if (event is CloseScreen) {
      yield updateResponse(Response()
        ..loading = true
        ..error = false
        ..requestType = RequestType.LOADING);
      yield* closescreen(event);
    } else if (event is Download) {
      yield updateResponse(Response()
        ..loading = true
        ..error = false
        ..requestType = RequestType.LOADING);
      yield* download(event);
    } else if (event is ApplicationStyle) {
      yield updateResponse(Response()
        ..loading = true
        ..error = false
        ..requestType = RequestType.LOADING);
      yield* applicationStyle(event);
    } else if (event is SetValues ||
        event is SelectRecord ||
        event is FetchData ||
        event is FilterData ||
        event is InsertRecord ||
        event is SaveData) {
      yield* data(event);
    } else if (event is PressButton) {
      yield updateResponse(Response()
        ..loading = true
        ..error = false
        ..requestType = RequestType.LOADING);
      yield* pressButton(event);
    } else if (event is Navigation) {
      yield updateResponse(Response()
        ..loading = true
        ..error = false
        ..requestType = RequestType.LOADING);
      yield* navigation(event);
    } else if (event is DeviceStatus) {
      yield updateResponse(Response()
        ..loading = true
        ..error = false
        ..requestType = RequestType.LOADING);
      yield* deviceStatus(event);
    } else if (event is Download) {
      yield updateResponse(Response()
        ..loading = true
        ..error = false
        ..requestType = RequestType.LOADING);
      yield* download(event);
    } else if (event is Upload) {
      yield updateResponse(Response()
        ..loading = true
        ..error = false
        ..requestType = RequestType.LOADING);
      yield* upload(event);
    } else if (event is Change) {
      yield updateResponse(Response()
        ..loading = true
        ..error = false
        ..requestType = RequestType.LOADING);
      yield* change(event);
    } else if (event is Loading) {
      yield Response()
        ..loading = true
        ..error = false
        ..requestType = RequestType.LOADING;
    } else if (event.requestType == RequestType.RELOAD) {
      yield Response()
        ..loading = false
        ..error = false
        ..requestType = RequestType.RELOAD;
    }
  }

  Stream<Response> startup(Startup request) async* {
    Map<String, String> authData =
        await SharedPreferencesHelper().getLoginData();

    if ((authData['username'] != null && authData['username'].isNotEmpty) &&
        (authData['password'] != null && authData['password'].isNotEmpty)) {
      globals.password = authData['password'];
      globals.username = authData['username'];
    }

    if (authData['authKey'] != null) {
      request.authKey = authData['authKey'];
    }

    Response resp = await processRequest(request);

    if (!resp.error) {
      if (resp != null && resp.applicationMetaData != null) {
        ApplicationMetaData applicationMetaData = resp.applicationMetaData;
        if (applicationMetaData != null) {
          globals.clientId = applicationMetaData.clientId;
          globals.language = applicationMetaData.langCode;
          globals.appVersion = applicationMetaData.version;
          Translations.load(Locale(globals.language));
        }
      }

      if (resp != null && resp.loginItem != null) {
        SharedPreferencesHelper().setAuthKey(null);
      }
    }

    yield resp;
  }

  Stream<Response> login(Login request) async* {
    globals.username = request.username;

    if (request.createAuthKey) {
      SharedPreferencesHelper().setLoginData(request.username, request.password);
    }
    Response resp = await processRequest(request);

    AuthenticationData authData;
    if (resp.authenticationData != null) authData = resp.authenticationData;

    if (authData != null)
      SharedPreferencesHelper().setAuthKey(authData.authKey);

    yield resp;
  }

  Stream<Response> logout(Logout request) async* {
    SharedPreferencesHelper().setLoginData('', '');
    globals.username = '';
    globals.password = '';
    yield await processRequest(request);
  }

  Stream<Response> openscreen(OpenScreen request) async* {
    prefix0.Action action = request.action;

    Response resp = await processRequest(request);

    if (!resp.error) resp.action = action;

    yield resp;
  }

  Stream<Response> data(Request request) async* {
    Response resp = await processRequest(request);

    yield resp;
  }

  Stream<Response> pressButton(PressButton request) async* {
    prefix0.Action action = request.action;

    Response resp = await processRequest(request);

    if (!resp.error) resp.action = action;

    yield resp;
  }

  Stream<Response> deviceStatus(Request request) async* {
    Response resp = await processRequest(request);

    yield resp;
  }

  Stream<Response> closescreen(CloseScreen request) async* {
    Response resp = await processRequest(request);

    yield resp;
  }

  Stream<Response> download(Download request) async* {
    Response resp = await processRequest(request);

    if (request.requestType == RequestType.DOWNLOAD) {
      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      var filename = '${directory.path}/${resp.downloadFileName}';

      var outFile = File(filename);
      outFile = await outFile.create(recursive: true);
      await outFile.writeAsBytes(resp.download);
    } else {
      var _dir;

      if (Platform.isIOS) {
        _dir = (await getApplicationSupportDirectory()).path;
      } else {
        _dir = (await getApplicationDocumentsDirectory()).path;
      }

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
    }

    yield resp;
  }

  Stream<Response> applicationStyle(ApplicationStyle request) async* {
    var _dir;

    if (Platform.isIOS) {
      _dir = (await getApplicationSupportDirectory()).path;
    } else {
      _dir = (await getApplicationDocumentsDirectory()).path;
    }

    globals.dir = _dir;

    Response resp = await processRequest(request);

    globals.applicationStyle = resp.applicationStyle;

    yield resp;
  }

  Stream<Response> navigation(Navigation request) async* {
    Response resp = await processRequest(request);

    if ((resp.screenGeneric != null &&
            resp.screenGeneric.changedComponents.isEmpty) &&
        resp.jVxData.isEmpty &&
        resp.jVxMetaData.isEmpty) {
      print('CLOSE REQUEST: ' + request.componentId);
      CloseScreen closeScreen = CloseScreen(
          clientId: globals.clientId,
          componentId: request.componentId,
          requestType: RequestType.CLOSE_SCREEN);

      dispatch(closeScreen);
    }

    yield resp;
  }

  Stream<Response> upload(Upload request) async* {
    Response resp = await processRequest(request);

    yield resp;
  }

  Stream<Response> change(Change request) async* {
    yield await processRequest(request);
  }

  Future<Response> processRequest(Request request) async {
    RestClient restClient = RestClient();
    Response response;

    switch (request.requestType) {
      case RequestType.STARTUP:
        response = await restClient.postAsync('/api/startup', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.LOGIN:
        response = await restClient.postAsync('/api/login', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.LOGOUT:
        response = await restClient.postAsync('/api/logout', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.OPEN_SCREEN:
        response =
            await restClient.postAsync('/api/v2/openScreen', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.CLOSE_SCREEN:
        response =
            await restClient.postAsync('/api/closeScreen', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.DAL_SELECT_RECORD:
        response = await restClient.postAsync(
            '/api/dal/selectRecord', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.DAL_SET_VALUE:
        response =
            await restClient.postAsync('/api/dal/setValues', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.DAL_FETCH:
        response =
            await restClient.postAsync('/api/dal/fetch', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.DAL_FILTER:
        response =
            await restClient.postAsync('/api/dal/filter', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.DAL_INSERT:
        response = await restClient.postAsync(
            '/api/dal/insertRecord', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.DAL_DELETE:
        response = await restClient.postAsync(
            '/api/dal/deleteRecord', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.DAL_SAVE:
        response =
            await restClient.postAsync('/api/dal/save', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.DOWNLOAD_TRANSLATION:
        response =
            await restClient.postAsyncDownload('/download', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        response.download = ZipDecoder().decodeBytes(response.download);
        updateResponse(response);
        return response;
        break;
      case RequestType.DOWNLOAD_IMAGES:
        response =
            await restClient.postAsyncDownload('/download', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        response.download = ZipDecoder().decodeBytes(response.download);
        updateResponse(response);
        return response;
        break;
      case RequestType.APP_STYLE:
        response = await restClient.postAsync('/download', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.PRESS_BUTTON:
        response =
            await restClient.postAsync('/api/v2/pressButton', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.NAVIGATION:
        response =
            await restClient.postAsync('/api/navigation', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.DEVICE_STATUS:
        response =
            await restClient.postAsync('/api/deviceStatus', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.LOADING:
        // Just loading.
        break;
      case RequestType.DOWNLOAD:
        response =
            await restClient.postAsyncDownload('/download', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.UPLOAD:
        response = await restClient.postAsyncUpload('/upload', request);
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.CHANGE:
        response = await restClient.postAsync('/api/changes', request.toJson());
        response.requestType = request.requestType;
        response.request = request;
        updateResponse(response);
        return response;
        break;
      case RequestType.RELOAD:
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
    if (toUpdate.language == null) toUpdate.language = currentResponse.language;
    //if (toUpdate.jVxData == null)
    //  toUpdate.jVxData = currentResponse.jVxData;
    //if (toUpdate.jVxMetaData == null)
    //  toUpdate.jVxMetaData = currentResponse.jVxMetaData;
    if (toUpdate.loginItem == null)
      toUpdate.loginItem = currentResponse.loginItem;
    if (toUpdate.menu == null) toUpdate.menu = currentResponse.menu;
    //if (toUpdate.screenGeneric == null)
    //  toUpdate.screenGeneric = currentResponse.screenGeneric;

    return toUpdate;
  }
}
