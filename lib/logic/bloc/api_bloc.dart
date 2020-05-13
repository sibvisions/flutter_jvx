import 'dart:collection';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import '../../model/api/request/set_component_value.dart';
import '../../model/action.dart' as prefix0;
import '../../model/api/request/change.dart';
import '../../model/api/request/data/fetch_data.dart';
import '../../model/api/request/data/filter_data.dart';
import '../../model/api/request/data/insert_record.dart';
import '../../model/api/request/data/save_data.dart';
import '../../model/api/request/data/set_values.dart';
import '../../model/api/request/data/select_record.dart';
import '../../model/api/request/device_Status.dart';
import '../../model/api/request/loading.dart';
import '../../model/api/request/navigation.dart';
import '../../model/api/request/press_button.dart';
import '../../model/api/request/request.dart';
import '../../model/api/request/upload.dart';
import '../../model/api/response/response.dart';
import '../../model/api/response/application_meta_data.dart';
import '../../model/api/request/application_style.dart';
import '../../model/api/response/auth_data.dart';
import '../../model/api/request/close_screen.dart';
import '../../model/api/request/download.dart';
import '../../model/api/request/login.dart';
import '../../model/api/request/logout.dart';
import '../../model/api/request/open_screen.dart';
import '../../model/api/request/startup.dart';
import '../../services/rest_client.dart';
import '../../utils/app_config.dart';
import '../../utils/shared_preferences_helper.dart';
import 'package:connectivity/connectivity.dart';
import '../../utils/globals.dart' as globals;
import '../../utils/translations.dart';
import 'package:path_provider/path_provider.dart';
import '../../model/api/request/data/meta_data.dart'
    as dataModel;

class ApiBloc extends Bloc<Request, Response> {
  Queue<Request> _queue = Queue<Request>();
  int seqNo = 0;

  @override
  Response get initialState => Response()..loading = true;

  @override
  void onEvent(Request event) {
    if (event.requestType != RequestType.RELOAD) {
      event.sequenceNo = seqNo++;
      print("~~~ Outgoing Request id: ${event.sequenceNo}");
    }
    _queue.add(event);
    super.onEvent(event);
  }

  @override
  Stream<Response> mapEventToState(Request event) async* {
    if (await _checkConnectivity()) {
      if (_queue.length != null) {
        await for (Response response in makeRequest(_queue.removeFirst())) {
          if (response.requestType != RequestType.LOADING &&
              response.requestType != RequestType.RELOAD) {
            print("~~~ Incoming Response id: ${response.request.sequenceNo}");
          }

          if (response.request?.subsequentRequest != null) {
            _queue.add(response.request.subsequentRequest);
            mapEventToState(response.request.subsequentRequest);
          }

          yield response;
        }
      }
    } else {
      _queue.removeLast();
      yield updateResponse(Response()
        ..title = 'Connection Error'
        ..errorName = 'internet.error'
        ..error = true
        ..message = 'No connection to the Internet');
    }
  }

  Stream<Response> makeRequest(Request event) async* {
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
        event is SaveData ||
        event is dataModel.MetaData ||
        event is SetComponentValue) {
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
      request.userName = null;
      request.password = null;
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

    if (!globals.package) {
      AppConfig.loadFile().then((AppConfig appConf) {
        globals.handleSessionTimeout = appConf.handleSessionTimeout;
      });
    }

    yield resp;
  }

  Stream<Response> login(Login request) async* {
    globals.username = request.username;

    if (request.createAuthKey) {
      SharedPreferencesHelper()
          .setLoginData(request.username, request.password);
    }
    Response resp = await processRequest(request);

    AuthenticationData authData;
    if (resp.authenticationData != null) authData = resp.authenticationData;

    if (authData != null)
      SharedPreferencesHelper().setAuthKey(authData.authKey);

    yield resp;
  }

  Stream<Response> logout(Logout request) async* {
    Response resp = await processRequest(request);

    SharedPreferencesHelper().setLoginData('', '');
    SharedPreferencesHelper().setAuthKey(null);
    //globals.username = '';
    //globals.password = '';
    //globals.profileImage = '';
    //globals.displayName = '';

    yield resp;
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
        Directory directory = Directory('${globals.dir}/translations');

        if (directory.existsSync()) {
          directory.listSync().forEach((entity) {
            if (entity.path !=
                '${globals.dir}/translations/${globals.baseUrl.split('/')[2]}') {
              Directory appNameDir = Directory(entity.path);

              appNameDir.deleteSync(recursive: true);

              // appNameDir.listSync().forEach((appNameEntity) {
              //   if (appNameEntity.path != '${globals.dir}/translations/${globals.baseUrl.split('/')[2]}') {
              //     Directory appVersionDir = Directory(appNameEntity.path);

              //     appVersionDir.deleteSync();
              //   }
              // });
            }
          });
        }

        var archive = resp.download;

        globals.translation = <String, String>{};

        String trimmedUrl = globals.baseUrl.split('/')[2];

        for (var file in archive) {
          var filename =
              '$_dir/translations/$trimmedUrl/${globals.appName}/${globals.appVersion}/${file.name}';
          if (file.isFile) {
            var outFile = File(filename);
            globals.translation[file.name] = '$filename';
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

    if ((resp.responseData.screenGeneric != null &&
            resp.responseData.screenGeneric.changedComponents.isEmpty) &&
        resp.responseData.jVxData.isEmpty &&
        resp.responseData.jVxMetaData.isEmpty) {
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
      case RequestType.DAL_METADATA:
        response =
            await restClient.postAsync('/api/dal/metaData', request.toJson());
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
      case RequestType.SET_VALUE:
        response =
            await restClient.postAsync('/api/comp/setValue', request.toJson());
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
    if (toUpdate.userData == null) toUpdate.userData = currentResponse.userData;

    return toUpdate;
  }

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}
