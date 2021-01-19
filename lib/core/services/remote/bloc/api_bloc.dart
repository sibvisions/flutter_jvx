import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/core/services/local/local_database/i_offline_database_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/prefer_universal/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import '../../../models/api/request.dart';
import '../../../models/api/request/application_style.dart';
import '../../../models/api/request/change.dart' as req;
import '../../../models/api/request/close_screen.dart';
import '../../../models/api/request/data/fetch_data.dart';
import '../../../models/api/request/data/filter_data.dart';
import '../../../models/api/request/data/insert_record.dart';
import '../../../models/api/request/data/meta_data.dart' as dataModel;
import '../../../models/api/request/data/save_data.dart';
import '../../../models/api/request/data/select_record.dart';
import '../../../models/api/request/data/set_values.dart';
import '../../../models/api/request/device_status.dart';
import '../../../models/api/request/download.dart';
import '../../../models/api/request/loading.dart';
import '../../../models/api/request/login.dart';
import '../../../models/api/request/logout.dart';
import '../../../models/api/request/menu.dart';
import '../../../models/api/request/navigation.dart';
import '../../../models/api/request/open_screen.dart';
import '../../../models/api/request/press_button.dart';
import '../../../models/api/request/set_component_value.dart';
import '../../../models/api/request/startup.dart';
import '../../../models/api/request/tab_close.dart';
import '../../../models/api/request/tab_select.dart';
import '../../../models/api/request/upload.dart';
import '../../../models/api/response.dart';
import '../../../models/app/app_state.dart';
import '../../../utils/app/get_local_file_path.dart';
import '../../../utils/network/network_info.dart';
import '../../../utils/translation/app_localizations.dart';
import '../../local/shared_preferences_manager.dart';
import '../rest/rest_client.dart';

class ApiBloc extends Bloc<Request, Response> {
  final NetworkInfo networkInfo;
  final RestClient restClient;
  final AppState appState;
  final SharedPreferencesManager manager;
  final IOfflineDatabaseProvider offlineDb;

  Queue<Request> _requestQueue = Queue<Request>();
  int _seqNo = 0;
  int lastYieldTime = 0;

  ApiBloc(Response initialState, this.networkInfo, this.restClient,
      this.appState, this.manager, this.offlineDb)
      : super(initialState);

  @override
  void onEvent(Request event) {
    if (event.requestType != RequestType.RELOAD) {
      event.id = _seqNo++;
      print(
          '******* Outgoing RequestID: ${event.id}, Type: ${event.requestType.toString().replaceAll("RequestType.", "")} (${event.debugInfo})');
    }
    _requestQueue.add(event);
    super.onEvent(event);
  }

  @override
  Stream<Response> mapEventToState(Request event) async* {
    if (this.appState.isOffline && this.offlineDb.isOpen) {
      yield* this.offlineDb.request(event);
    } else if (await this.networkInfo.isConnected) {
      yield updateResponse(Response()..request = Loading());
      await for (Response response
          in makeRequest(_requestQueue.removeFirst())) {
        if (response.request.requestType != RequestType.LOADING &&
            response.request.requestType != RequestType.RELOAD) {
          print(
              '******* Incoming RequestID: ${response.request.id}, Type: ${response.request.requestType.toString().replaceAll("RequestType.", "")} (${response.request.debugInfo})');
        }

        int diff =
            ((new DateTime.now().millisecondsSinceEpoch) - lastYieldTime);
        if (diff < 100)
          await Future.delayed(Duration(milliseconds: 100 - diff), () {});

        /*if (response.request.requestType == RequestType.DAL_FETCH) {
          print("ApiBloc yield with dal_fetch dataProvider " +
              (response.request as FetchData).dataProvider +
              " (" +
              (new DateTime.now().millisecondsSinceEpoch).toString() +
              ")");
        }

        print("lastYieldTime: " +
            lastYieldTime.toString() +
            "(" +
            ((new DateTime.now().millisecondsSinceEpoch) - lastYieldTime)
                .toString() +
            ")");
        */

        lastYieldTime = new DateTime.now().millisecondsSinceEpoch;

        yield response;
      }
    }
  }

  Stream<Response> makeRequest(Request event) async* {
    if (event is Startup) {
      yield* startup(event);
    } else if (event is ApplicationStyle) {
      yield* applicationStyle(event);
    } else if (event is Download) {
      yield* download(event);
    } else if (event is Login) {
      yield* login(event);
    } else if (event is Logout) {
      yield* logout(event);
    } else if (event is OpenScreen) {
      yield* openScreen(event);
    } else if (event is CloseScreen) {
      yield* closeScreen(event);
    } else if (event is Navigation) {
      yield* navigation(event);
    } else if (event is DeviceStatus) {
      yield* deviceStatus(event);
    } else if (event is req.Change) {
      yield* change(event);
    } else if (event is Menu) {
      yield* menu(event);
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
      yield* pressButton(event);
    } else if (event is Upload) {
      yield* upload(event);
    } else if (event is TabSelect) {
      yield* tabSelect(event);
    } else if (event is TabClose) {
      yield* tabClose(event);
    }
  }

  Stream<Response> startup(Startup event) async* {
    Response response = await processRequest(event);

    yield response;
  }

  Stream<Response> login(Login event) async* {
    this.appState.username = event.username;

    if (event.createAuthKey) {
      this
          .manager
          .setLoginData(username: event.username, password: event.password);
    }

    Response response = await processRequest(event);

    if (response.authenticationData != null) {
      this.manager.setAuthKey(response.authenticationData.authKey);
    }

    yield response;
  }

  Stream<Response> applicationStyle(ApplicationStyle event) async* {
    Response response = await processRequest(event);

    if (!kIsWeb) {
      if (Platform.isIOS) {
        this.appState.dir = (await getApplicationSupportDirectory()).path;
      } else {
        this.appState.dir = (await getApplicationDocumentsDirectory()).path;
      }
    } else {
      this.appState.dir = '';
    }

    yield response;
  }

  Stream<Response> download(Download event) async* {
    Response response = await processRequest(event);

    if (!response.hasError) {
      if (kIsWeb)
        yield* _downloadWeb(event, response);
      else
        yield* _downloadMobile(event, response);
    }
  }

  Stream<Response> _downloadWeb(Download event, Response response) async* {
    response.downloadResponse.fileName = this.manager.downloadFileName;

    if (event.requestType == RequestType.DOWNLOAD) {
      final blob = html.Blob([response.downloadResponse?.download]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = response.downloadResponse.fileName;
      html.document.body.children.add(anchor);

      // download
      anchor.click();

      // cleanup
      html.document.body.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else if (event.requestType == RequestType.DOWNLOAD_TRANSLATION) {
      this.appState.translation = <String, dynamic>{};
      this.appState.files = <String, String>{};

      for (var file in response.downloadResponse?.download) {
        String filename = getLocalFilePath(this.appState.baseUrl, '',
                this.appState.appName, this.appState.appVersion) +
            '/' +
            file.name;

        if (file.isFile) {
          this
              .appState
              .files
              .putIfAbsent(filename, () => utf8.decode((file.content)));
          this.appState.translation[file.name] = '$filename';

          String trimmedFilename = file.name;
          if (trimmedFilename.contains('_')) {
            trimmedFilename = trimmedFilename.substring(
                trimmedFilename.indexOf('_'), trimmedFilename.indexOf('.'));
          } else {
            trimmedFilename = 'en';
          }
          this.appState.supportedLocales.firstWhere(
              (locale) => locale.languageCode == trimmedFilename, orElse: () {
            this.appState.supportedLocales.add(Locale(trimmedFilename));
            return null;
          });
        }
      }

      this.manager.setTranslation(appState.translation);
      AppLocalizations.load(Locale(appState.language));
    } else if (event.requestType == RequestType.DOWNLOAD_IMAGES) {
      for (var file in response.downloadResponse?.download) {
        String filename = '/${file.name}';
        if (file.isFile) {
          this
              .appState
              .files
              .putIfAbsent(filename, () => utf8.decode(file.content));
        }
      }
    }

    yield response;
  }

  Stream<Response> _downloadMobile(Download event, Response response) async* {
    if (event.requestType == RequestType.DOWNLOAD) {
      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      String filename =
          '${directory.path}/${response.downloadResponse.fileName}';

      File outFile = File(filename);
      outFile = await outFile.create(recursive: true);
      await outFile.writeAsBytes(response.downloadResponse?.download);
    } else {
      String _baseDir = Platform.isIOS
          ? (await getApplicationSupportDirectory()).path
          : (await getApplicationDocumentsDirectory()).path;

      this.appState.dir = _baseDir;

      if (event.requestType == RequestType.DOWNLOAD_TRANSLATION) {
        this.appState.translation = <String, String>{};
        Directory directory = Directory('$_baseDir/translations');

        if (directory.existsSync()) {
          directory.listSync().forEach((entity) {
            if (entity.path !=
                getLocalFilePath(this.appState.baseUrl, _baseDir, '', '')) {
              Directory appNameDirectory = Directory(entity.path);

              appNameDirectory.deleteSync(recursive: true);
            }
          });
        }

        for (var file in response.downloadResponse?.download) {
          var filename = getLocalFilePath(this.appState.baseUrl, _baseDir,
                  this.appState.appName, this.appState.appVersion) +
              '/' +
              file.name;

          if (file.isFile) {
            var outFile = File(filename);
            this.appState.translation.putIfAbsent(file.name, () => '$filename');
            outFile = await outFile.create(recursive: true);
            await outFile.writeAsBytes(file.content);

            String trimmedFilename = file.name;
            if (trimmedFilename.contains('_')) {
              trimmedFilename = trimmedFilename.substring(
                  trimmedFilename.indexOf('_') + 1,
                  trimmedFilename.indexOf('.'));
            } else {
              trimmedFilename = 'en';
            }
            this.appState.supportedLocales.firstWhere(
                (locale) => locale.languageCode == trimmedFilename, orElse: () {
              this.appState.supportedLocales.add(Locale(trimmedFilename));
              return null;
            });
          }
        }

        this.manager.setTranslation(this.appState.translation);
        if (appState.language != null && appState.language.isNotEmpty)
          AppLocalizations.load(Locale(this.appState.language));
      } else if (event.requestType == RequestType.DOWNLOAD_IMAGES) {
        for (var file in response.downloadResponse?.download) {
          var filename = '$_baseDir/${file.name}';
          if (file.isFile) {
            var outFile = File(filename);
            this.appState.images.add(filename);
            outFile = await outFile.create(recursive: true);
            await outFile.writeAsBytes(file.content);
          }
        }
      }
    }

    yield response;
  }

  Stream<Response> logout(Logout event) async* {
    Response response = await processRequest(event);

    this.manager.setLoginData(username: null, password: null, override: true);
    this.manager.setAuthKey(null);

    yield response;
  }

  Stream<Response> openScreen(OpenScreen event) async* {
    Response response = await processRequest(event);

    if (!response.hasError) {
      this.appState.currentScreenComponentId = event.action.componentId;
    }

    yield response;
  }

  Stream<Response> data(Request request) async* {
    Response resp = await processRequest(request);

    yield resp;
  }

  Stream<Response> deviceStatus(DeviceStatus request) async* {
    Response resp = await processRequest(request);

    if (resp.deviceStatusResponse?.layoutMode != null) {
      this.appState.layoutMode = resp.deviceStatusResponse.layoutMode;
    }

    yield resp;
  }

  Stream<Response> closeScreen(CloseScreen request) async* {
    Response resp = await processRequest(request);

    yield resp;
  }

  Stream<Response> navigation(Navigation request) async* {
    Response resp = await processRequest(request);

    if ((resp.responseData.screenGeneric != null &&
            resp.responseData.screenGeneric.changedComponents.isEmpty) &&
        resp.responseData.dataBooks.isEmpty &&
        resp.responseData.dataBookMetaData.isEmpty) {
      print('CLOSE REQUEST: ' + request.componentId);
      CloseScreen closeScreen = CloseScreen(
          clientId: this.appState.clientId,
          componentId: request.componentId,
          requestType: RequestType.CLOSE_SCREEN);

      add(closeScreen);
    }

    yield resp;
  }

  Stream<Response> change(req.Change event) async* {
    yield await processRequest(event);
  }

  Stream<Response> menu(Menu request) async* {
    yield await processRequest(request);
  }

  Stream<Response> pressButton(PressButton event) async* {
    Response response = await processRequest(event);

    if (response.showDocument != null) {
      if (await canLaunch(response.showDocument.document)) {
        await launch(response.showDocument.document);
      } else {
        throw 'Could not launch ${response.showDocument.document}';
      }
    }

    yield response;
  }

  Stream<Response> upload(Upload event) async* {
    Response resp = await processRequest(event);

    yield resp;
  }

  Stream<Response> tabSelect(TabSelect request) async* {
    yield await processRequest(request);
  }

  Stream<Response> tabClose(TabClose request) async* {
    yield await processRequest(request);
  }

  Future<Response> processRequest(Request event) async {
    Response response;

    switch (event.requestType) {
      case RequestType.STARTUP:
        response = await this
            .restClient
            .post(this.appState.baseUrl + '/api/startup', event.toJson());
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.LOGIN:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/v2/login',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.LOGOUT:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/logout',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.OPEN_SCREEN:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/v2/openScreen',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.CLOSE_SCREEN:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/closeScreen',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.DOWNLOAD_TRANSLATION:
        response = await this.restClient.download(
            this.appState.baseUrl + '/download',
            event.toJson(),
            this.manager.downloadFileName);
        response.downloadResponse?.download =
            ZipDecoder().decodeBytes(response.downloadResponse?.download);
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.DOWNLOAD_IMAGES:
        response = await this.restClient.download(
            this.appState.baseUrl + '/download',
            event.toJson(),
            this.manager.downloadFileName);
        response.downloadResponse?.download =
            ZipDecoder().decodeBytes(response.downloadResponse?.download);
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.APP_STYLE:
        response = await this.restClient.post(
              this.appState.baseUrl + '/download',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.DAL_SELECT_RECORD:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/dal/selectRecord',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.DAL_SET_VALUE:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/dal/setValues',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.DAL_FETCH:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/dal/fetch',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.DAL_DELETE:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/dal/deleteRecord',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.DAL_FILTER:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/dal/filter',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.DAL_INSERT:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/dal/insertRecord',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.DAL_SAVE:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/dal/save',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.DAL_METADATA:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/dal/metaData',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.PRESS_BUTTON:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/v2/pressButton',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.NAVIGATION:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/navigation',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.LOADING:
        response = updateResponse(Response());
        break;
      case RequestType.RELOAD:
        response = updateResponse(Response());
        break;
      case RequestType.DEVICE_STATUS:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/deviceStatus',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.DOWNLOAD:
        response = await this.restClient.download(
            this.appState.baseUrl + '/download',
            event.toJson(),
            this.manager.downloadFileName);
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.UPLOAD:
        response = await this
            .restClient
            .upload(this.appState.baseUrl + '/upload', event);
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.CHANGE:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/changes',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.SET_VALUE:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/comp/setValue',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.TAB_SELECT:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/comp/selectTab',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.TAB_CLOSE:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/comp/closeTab',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
      case RequestType.MENU:
        response = await this.restClient.post(
              this.appState.baseUrl + '/api/menu',
              event.toJson(),
            );
        response.request = event;
        updateResponse(response);
        break;
    }

    return response;
  }

  updateResponse(Response response) {
    Response currentResponse = state;
    Response toUpdate = response;

    if (currentResponse != null) {
      if (response.applicationMetaData == null)
        response.applicationMetaData = currentResponse.applicationMetaData;
      if (response.applicationStyle == null)
        response.applicationStyle = currentResponse.applicationStyle;
      if (response.authenticationData == null)
        response.authenticationData = currentResponse.authenticationData;
      if (response.language == null)
        response.language = currentResponse.language;
      if (response.loginItem == null)
        response.loginItem = currentResponse.loginItem;
      if (response.menu == null) response.menu = currentResponse.menu;
      if (response.userData == null)
        response.userData = currentResponse.userData;
    }
    
    return toUpdate;
  }
}
