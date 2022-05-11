import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_client/src/service/api/shared/processor/authentication_data_processor.dart';
import 'package:flutter_client/src/service/api/shared/processor/dal_data_provider_changed_processor.dart';
import 'package:flutter_client/src/service/api/shared/processor/login_processor.dart';
import 'package:flutter_client/src/service/api/shared/processor/session_expired_processor.dart';
import 'package:flutter_client/src/service/api/shared/processor/user_data_processor.dart';
import 'package:flutter_client/util/download/download_helper.dart';

import '../../../../model/api/api_response_names.dart';
import '../../../../model/api/response/api_response.dart';
import '../../../../model/command/base_command.dart';
import '../i_controller.dart';
import '../i_processor.dart';
import '../processor/application_meta_data_processor.dart';
import '../processor/application_parameters_processor.dart';
import '../processor/close_screen_processor.dart';
import '../processor/dal_fetch_processor.dart';
import '../processor/dal_meta_data_processor.dart';
import '../processor/error_processor.dart';
import '../processor/menu_processor.dart';
import '../processor/screen_generic_processor.dart';

class ApiController implements IController {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final IProcessor _applicationParameterProcessor = ApplicationParametersProcessor();
  final IProcessor _applicationMetaDataProcessor = ApplicationMetaDataProcessor();
  final IProcessor _menuProcessor = MenuProcessor();
  final IProcessor _screenGenericProcessor = ScreenGenericProcessor();
  final IProcessor _closeScreenProcessor = CloseScreenProcessor();
  final IProcessor _dalMetaDataProcessor = DalMetaDataProcessor();
  final IProcessor _dalFetchProcessor = DalFetchProcessor();
  final IProcessor _userDataProcessor = UserDataProcessor();
  final IProcessor _loginProcessor = LoginProcessor();
  final IProcessor _errorProcessor = ErrorProcessor();
  final IProcessor _sessionExpiredProcessor = SessionExpiredProcessor();
  final IProcessor _dalDataProviderChangedProcessor = DalDataProviderChangedProcessor();
  final IProcessor _authenticationDataProcessor = AuthenticationDataProcessor();

  /// Maps response names to their processor
  late final Map<String, IProcessor> responseToProcessorMap;

  /// Decoder used for decoding the application images and translations
  final ZipDecoder _zipDecoder = ZipDecoder();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiController() {
    responseToProcessorMap = {
      ApiResponseNames.applicationParameters: _applicationParameterProcessor,
      ApiResponseNames.applicationMetaData: _applicationMetaDataProcessor,
      ApiResponseNames.menu: _menuProcessor,
      ApiResponseNames.screenGeneric: _screenGenericProcessor,
      ApiResponseNames.closeScreen: _closeScreenProcessor,
      ApiResponseNames.dalMetaData: _dalMetaDataProcessor,
      ApiResponseNames.dalFetch: _dalFetchProcessor,
      ApiResponseNames.userData: _userDataProcessor,
      ApiResponseNames.login: _loginProcessor,
      ApiResponseNames.error: _errorProcessor,
      ApiResponseNames.sessionExpired: _sessionExpiredProcessor,
      ApiResponseNames.dalDataProviderChanged: _dalDataProviderChangedProcessor,
      ApiResponseNames.authenticationData: _authenticationDataProcessor,
    };
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse({required List<ApiResponse> responses}) {
    List<BaseCommand> commands = [];

    for (ApiResponse response in responses) {
      IProcessor? processor = responseToProcessorMap[response.name];

      if (processor != null) {
        commands.addAll(processor.processResponse(pResponse: response));
      } else {
        throw Exception("Couldn't find processor belonging to ${response.name}, add it to the map");
      }
    }

    return commands;
  }

  @override
  List<BaseCommand> processImageDownload({
    required Uint8List response,
    required String baseDir,
    required String appName,
    required String appVersion,
  }) {
    Archive archive = _zipDecoder.decodeBytes(response);
    String baseFilePath = DownloadHelper.getLocalFilePath(appName: appName, appVersion: appVersion, translation: false, baseDir: baseDir);

    if (!kIsWeb) {
      // Save files to disk
      for (ArchiveFile file in archive) {
        // Create file
        File outputFile = File('$baseFilePath/${file.name}');
        Future<File> createdFile = outputFile.create(recursive: true);
        // Write file
        createdFile.then((value) => value.writeAsBytes(file.content));
      }
    } else {
      //ToDo implement return command to save images in RAM in main thread
    }

    return [];
  }
}
