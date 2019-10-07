import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/model/application_meta_data.dart';
import 'package:jvx_mobile_v3/model/close_screen/close_screen.dart';
import 'package:jvx_mobile_v3/model/download/download.dart';
import 'package:jvx_mobile_v3/model/login/login.dart';
import 'package:jvx_mobile_v3/model/logout/logout.dart';
import 'package:jvx_mobile_v3/model/open_screen/open_screen.dart';
import 'package:jvx_mobile_v3/model/startup/startup.dart';
import 'package:jvx_mobile_v3/services/new_rest_client.dart';
import 'package:jvx_mobile_v3/utils/shared_preferences_helper.dart';

import 'package:jvx_mobile_v3/utils/globals.dart' as globals;
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
    }
  }

  Stream<Response> startup(Startup request) async* {
    Map<String, String> authData =
        await SharedPreferencesHelper().getLoginData();

    if (authData['authKey'] != null) {
      request.authKey = authData['authKey'];
    }

    Response resp = await processRequest(request);

    if (resp.error == null || !resp.error) {
      if (resp != null &&
          resp.responseObjects != null &&
          resp.responseObjects.length > 0) {
        ApplicationMetaData applicationMetaData = (resp.responseObjects
                .firstWhere((r) => r is ApplicationMetaData, orElse: () => null)
            as ApplicationMetaData);
        if (applicationMetaData != null)
          globals.clientId = applicationMetaData.clientId;
      }
    }

    yield resp;
  }

  Stream<Response> login(Login request) async* {
    Response resp = await processRequest(request);

    yield resp;
  }

  Stream<Response> logout(Logout request) async* {
    yield await processRequest(request);
  }

  Stream<Response> openscreen(OpenScreen request) async* {
    yield await processRequest(request);
  }

  Stream<Response> closescreen(CloseScreen request) async* {
    yield await processRequest(request);
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

  Future<Response> processRequest(Request request) async {
    RestClient restClient = RestClient();
    Response response;

    switch (request.requestType) {
      case RequestType.STARTUP:
        response = await restClient.postAsync('/api/startup', request.toJson());
        response.requestType = request.requestType;
        return response;
        break;
      case RequestType.LOGIN:
        response = await restClient.postAsync('/api/login', request.toJson());
        response.requestType = request.requestType;
        return response;
        break;
      case RequestType.LOGOUT:
        response = await restClient.postAsync('/api/logout', request.toJson());
        response.requestType = request.requestType;
        return response;
        break;
      case RequestType.OPEN_SCREEN:
        response =
            await restClient.postAsync('/api/openScreen', request.toJson());
        response.requestType = request.requestType;
        break;
      case RequestType.CLOSE_SCREEN:
        response =
            await restClient.postAsync('/api/closeScreen', request.toJson());
        response.requestType = request.requestType;
        break;
      case RequestType.DAL_SELECT_RECORD:
        response = await restClient.postAsync(
            '/api/dal/selectRecord', request.toJson());
        response.requestType = request.requestType;
        break;
      case RequestType.DAL_SET_VALUE:
        response =
            await restClient.postAsync('/api/dal/setValue', request.toJson());
        response.requestType = request.requestType;
        break;
      case RequestType.DAL_FETCH:
        response =
            await restClient.postAsync('/api/dal/fetch', request.toJson());
        response.requestType = request.requestType;
        break;
      case RequestType.DOWNLOAD_TRANSLATION:
        response =
            await restClient.postAsyncDownload('/download', request.toJson());
        response.requestType = request.requestType;
        return response;
        break;
      case RequestType.DOWNLOAD_IMAGES:
        response =
            await restClient.postAsyncDownload('/download', request.toJson());
        response.requestType = request.requestType;
        return response;
        break;
      case RequestType.DOWNLOAD_APP_STYLE:
        // TODO: Handle this case.
        break;
    }

    return null;
  }
}
