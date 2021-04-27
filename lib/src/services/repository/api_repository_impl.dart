import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../injection_container.dart';
import '../../models/api/data_source.dart';
import '../../models/api/errors/failure.dart';
import '../../models/api/request.dart';
import '../../models/api/requests/application_style_request.dart';
import '../../models/api/requests/change_request.dart';
import '../../models/api/requests/close_screen_request.dart';
import '../../models/api/requests/data/data_request.dart';
import '../../models/api/requests/data/insert_record_request.dart';
import '../../models/api/requests/device_status_request.dart';
import '../../models/api/requests/download_images_request.dart';
import '../../models/api/requests/download_request.dart';
import '../../models/api/requests/download_translation_request.dart';
import '../../models/api/requests/login_request.dart';
import '../../models/api/requests/logout_request.dart';
import '../../models/api/requests/menu_request.dart';
import '../../models/api/requests/navigation_request.dart';
import '../../models/api/requests/open_screen_request.dart';
import '../../models/api/requests/press_button_request.dart';
import '../../models/api/requests/set_component_value.dart';
import '../../models/api/requests/startup_request.dart';
import '../../models/api/requests/tab_close_request.dart';
import '../../models/api/requests/tab_select_request.dart';
import '../../models/api/requests/upload_request.dart';
import '../../models/api/response_objects/authentication_data_response_object.dart';
import '../../models/api/response_objects/download_response_object.dart';
import '../../models/api/response_objects/login_response_object.dart';
import '../../models/api/response_objects/menu/menu_response_object.dart';
import '../../models/api/response_objects/show_document_response_object.dart';
import '../../models/state/app_state.dart';
import '../../services/local/local_database/i_offline_database_provider.dart';
import '../../services/local/locale/supported_locale_manager.dart';
import '../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../services/remote/cubit/api_cubit.dart';
import '../../services/remote/network_info/network_info.dart';
import '../../ui/util/error/error_handler.dart';
import '../../util/download/download_helper.dart';
import 'api_repository.dart';

class ApiRepositoryImpl implements ApiRepository {
  final DataSource dataSource;
  final IOfflineDatabaseProvider offlineDataSource;
  final NetworkInfo networkInfo;
  final AppState appState;
  final SharedPreferencesManager manager;
  final ZipDecoder decoder;

  ApiRepositoryImpl(
      {required this.dataSource,
      required this.networkInfo,
      required this.appState,
      required this.manager,
      required this.offlineDataSource,
      required this.decoder});

  @override
  Future<ApiState> applicationStyle(ApplicationStyleRequest request) async {
    return await _checkConnection(request, () {
      return dataSource.applicationStyle(request);
    });
  }

  @override
  Future<ApiState> change(ChangeRequest request) async {
    return await _checkConnection(request, () {
      return dataSource.change(request);
    });
  }

  @override
  Future<ApiState> closeScreen(CloseScreenRequest request) async {
    return await _checkConnection(request, () {
      return dataSource.closeScreen(request);
    });
  }

  @override
  Future<ApiState> deviceStatus(DeviceStatusRequest request) async {
    return await _checkConnection(request, () {
      return dataSource.deviceStatus(request);
    });
  }

  @override
  Future<ApiState> downloadImages(DownloadImagesRequest request) async {
    ApiState state = await _checkConnection(request, () {
      return dataSource.downloadImages(request);
    });

    if (state is ApiResponse) {
      await handleDownload(state);
    }

    return state;
  }

  @override
  Future<ApiState> downloadTranslation(
      DownloadTranslationRequest request) async {
    ApiState state = await _checkConnection(request, () {
      return dataSource.downloadTranslation(request);
    });

    if (state is ApiResponse) {
      await handleDownload(state);
    }

    return state;
  }

  @override
  Future<ApiState> login(LoginRequest request) async {
    if (!appState.isOffline) {
      ApiState state = await _checkConnection(request, () {
        return dataSource.login(request);
      });

      if (state is ApiResponse) {
        manager.setSyncLoginData(
            username: request.username, password: request.password);

        if (state.hasObject<AuthenticationDataResponseObject>())
          manager.authKey = state
              .getObjectByType<AuthenticationDataResponseObject>()!
              .authKey;
      }

      return state;
    } else {
      final offlineUsername = manager.offlineUsername;
      final offlinePassword = manager.offlinePassword;

      String usernameHash =
          sha256.convert(utf8.encode(request.username)).toString();
      String passwordHash =
          sha256.convert(utf8.encode(request.password)).toString();

      if (usernameHash == offlineUsername && passwordHash == offlinePassword) {
        return ApiResponse(request: request, objects: [
          LoginResponseObject(name: 'login', username: request.username),
          MenuResponseObject(name: 'menu', entries: [])
        ]);
      } else {
        return ApiError(
            failure: Failure(
                title: 'Login error',
                details: '',
                message: 'False username or password',
                name: 'message.error'));
      }
    }
  }

  @override
  Future<ApiState> logout(LogoutRequest request) async {
    if (!appState.isOffline) {
      ApiState state = await _checkConnection(request, () {
        return dataSource.logout(request);
      });

      if (state is ApiResponse) {
        manager.authKey = null;
        manager.userData = null;

        appState.userData = null;
      }

      return state;
    } else {
      return ApiResponse(request: request, objects: []);
    }
  }

  @override
  Future<ApiState> menu(MenuRequest request) async {
    return await _checkConnection(request, () {
      return dataSource.menu(request);
    });
  }

  @override
  Future<ApiState> navigation(NavigationRequest request) async {
    if (!appState.isOffline) {
      return await _checkConnection(request, () {
        return dataSource.navigation(request);
      });
    } else {
      return ApiResponse(request: request, objects: []);
    }
  }

  @override
  Future<ApiState> openScreen(OpenScreenRequest request) async {
    ApiState state = await _checkConnection(request, () {
      return dataSource.openScreen(request);
    });

    if (state is ApiResponse) {
      appState.currentMenuComponentId = request.componentId;
    }

    return state;
  }

  @override
  Future<ApiState> pressButton(PressButtonRequest request) async {
    return await _checkConnection(request, () async {
      ApiState state = await dataSource.pressButton(request);

      if (state is ApiResponse &&
          state.hasObject<ShowDocumentResponseObject>()) {
        ShowDocumentResponseObject showDocument =
            state.getObjectByType<ShowDocumentResponseObject>()!;

        if (showDocument.document != null &&
            showDocument.document!.isNotEmpty &&
            await canLaunch(showDocument.document!)) {
          await launch(showDocument.document!);
        } else {
          throw 'Could not launch ${showDocument.document}';
        }
      }

      return state;
    });
  }

  @override
  Future<ApiState> setComponentValue(SetComponentValueRequest request) async {
    return await _checkConnection(request, () {
      return dataSource.setComponentValue(request);
    });
  }

  @override
  Future<ApiState> startup(StartupRequest request) async {
    return await _checkConnection(request, () {
      return dataSource.startup(request);
    });
  }

  @override
  Future<ApiState> tabClose(TabCloseRequest request) async {
    return await _checkConnection(request, () {
      return dataSource.tabClose(request);
    });
  }

  @override
  Future<ApiState> tabSelect(TabSelectRequest request) async {
    return await _checkConnection(request, () {
      return dataSource.tabSelect(request);
    });
  }

  @override
  Future<ApiState> upload(UploadRequest request) async {
    return await _checkConnection(request, () {
      return dataSource.upload(request);
    });
  }

  @override
  Future<ApiState> download(DownloadRequest request) async {
    return await _checkConnection(request, () {
      return dataSource.download(request);
    });
  }

  @override
  Future<List<ApiState>> data(DataRequest request) async {
    if (!appState.isOffline) {
      List<ApiState> states = <ApiState>[];

      ApiState state = await _checkConnection(request, () {
        return dataSource.data(request);
      });

      states.add(state);

      if (request is InsertRecordRequest &&
          request.setValues != null &&
          state is ApiResponse &&
          !state.hasError) {
        states.add(await dataSource.data(request.setValues as DataRequest));
      }

      return states;
    } else {
      return [await offlineDataSource.request(request)];
    }
  }

  Future<ApiError?> handleDownload(ApiResponse response) async {
    bool isTranslation = (response.request is DownloadTranslationRequest);

    if (!kIsWeb) {
      deleteOutdatedData(
          baseUrl: appState.serverConfig!.baseUrl, translation: isTranslation);

      if (isTranslation) {
        manager.possibleTranslations = <String, dynamic>{};
      }
    }

    Archive? archive;

    try {
      archive = decoder.decodeBytes(
          response.getObjectByType<DownloadResponseObject>()!.bodyBytes);
    } on ArchiveException {
      return ApiError(
          failure: CacheFailure(
              name: ErrorHandler.cacheError,
              details: '',
              title: 'Download error',
              message: 'Could not decode file'));
    }

    late String localFilePath;

    if (!kIsWeb) {
      localFilePath = getLocalFilePath(
            baseDir: appState.baseDirectory,
            baseUrl: appState.serverConfig!.baseUrl,
            appName: appState.serverConfig!.appName,
            appVersion: appState.applicationMetaData!.version,
            translation: isTranslation,
          ) +
          '/';
    } else {
      localFilePath = '';
    }

    if (!isTranslation) {
      appState.fileConfig.images.clear();
    }

    for (final file in archive) {
      final filename = '$localFilePath${file.name}';

      if (!kIsWeb) {
        if (file.isFile) {
          var outputFile = File(filename);

          outputFile = await outputFile.create(recursive: true);

          await outputFile.writeAsBytes(file.content);

          if (isTranslation) {
            appState.translationConfig.possibleTranslations
                .putIfAbsent(file.name, () => '$filename');

            String trimmedFilename = file.name;

            if (trimmedFilename.contains('_')) {
              trimmedFilename = trimmedFilename.substring(
                  trimmedFilename.indexOf('_') + 1,
                  trimmedFilename.indexOf('.'));
            } else {
              trimmedFilename = 'en';
            }

            if (!appState.translationConfig.supportedLocales
                .contains(Locale(trimmedFilename))) {
              appState.translationConfig.supportedLocales
                  .add(Locale(trimmedFilename));
            }
          } else {
            appState.fileConfig.images.add(filename);
          }
        }
      } else {
        if (isTranslation) {
          appState.translationConfig.possibleTranslations
              .putIfAbsent(file.name, () => filename);

          String trimmedFilename = file.name;

          if (trimmedFilename.contains('_')) {
            trimmedFilename = trimmedFilename.substring(
                trimmedFilename.indexOf('_') + 1, trimmedFilename.indexOf('.'));
          } else {
            trimmedFilename = 'en';
          }

          if (!appState.translationConfig.supportedLocales
              .contains(Locale(trimmedFilename))) {
            appState.translationConfig.supportedLocales
                .add(Locale(trimmedFilename));
          }
        } else {
          appState.fileConfig.images.add(filename);
        }

        if (file.isFile) {
          appState.fileConfig.files
              .putIfAbsent('/${file.name}', () => utf8.decode(file.content));
        }
      }
    }

    if (isTranslation) {
      manager.possibleTranslations =
          appState.translationConfig.possibleTranslations;

      sl<SupportedLocaleManager>().value =
          appState.translationConfig.supportedLocales;
    } else {
      manager.savedImages = appState.fileConfig.images;
    }
  }

  _checkConnection(Request request, Future Function() onConnection) async {
    if (!kIsWeb) {
      if (!(await networkInfo.isConnected)) {
        return ApiError(
            failure: ServerFailure(
                title: 'Connection problems.',
                message: 'Could not ping server!',
                details: '',
                name: ErrorHandler.connectionError));
      } else if (appState.isOffline) {
        return await offlineDataSource.request(request);
      }
    }

    return await onConnection();
  }
}
