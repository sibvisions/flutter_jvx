import 'dart:collection';

import 'package:flutter_client/src/service/api/shared/processor/authentication_data_processor.dart';
import 'package:flutter_client/src/service/api/shared/processor/dal_data_provider_changed_processor.dart';
import 'package:flutter_client/src/service/api/shared/processor/download_images_processor.dart';
import 'package:flutter_client/src/service/api/shared/processor/download_style_processor.dart';
import 'package:flutter_client/src/service/api/shared/processor/download_translation_processor.dart';
import 'package:flutter_client/src/service/api/shared/processor/login_processor.dart';
import 'package:flutter_client/src/service/api/shared/processor/session_expired_processor.dart';

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
import '../processor/message_dialog_processor.dart';
import '../processor/screen_generic_processor.dart';
import '../processor/user_data_processor.dart';

class ApiController implements IController {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final IProcessor _applicationParameterProcessor = ApplicationParametersProcessor();
  final IProcessor _applicationMetaDataProcessor = ApplicationMetaDataProcessor();
  final IProcessor _menuProcessor = MenuProcessor();
  final IProcessor _closeScreenProcessor = CloseScreenProcessor();
  final IProcessor _screenGenericProcessor = ScreenGenericProcessor();
  final IProcessor _dalMetaDataProcessor = DalMetaDataProcessor();
  final IProcessor _dalFetchProcessor = DalFetchProcessor();
  final IProcessor _userDataProcessor = UserDataProcessor();
  final IProcessor _loginProcessor = LoginProcessor();
  final IProcessor _errorProcessor = ErrorProcessor();
  final IProcessor _sessionExpiredProcessor = SessionExpiredProcessor();
  final IProcessor _dalDataProviderChangedProcessor = DalDataProviderChangedProcessor();
  final IProcessor _authenticationDataProcessor = AuthenticationDataProcessor();
  final IProcessor _downloadImagesProcessor = DownloadImagesProcessor();
  final IProcessor _downloadTranslationProcessor = DownloadTranslationProcessor();
  final IProcessor _downloadStyleProcessor = DownloadStyleProcessor();
  final IProcessor _messageDialogProcessor = MessageDialogProcessor();

  /// Maps response names to their processor
  late final HashMap<String, IProcessor> responseToProcessorMap;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiController() {
    responseToProcessorMap = HashMap.from({
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
      ApiResponseNames.downloadImages: _downloadImagesProcessor,
      ApiResponseNames.downloadTranslation: _downloadTranslationProcessor,
      ApiResponseNames.messageDialog: _messageDialogProcessor,
      ApiResponseNames.downloadStyle: _downloadStyleProcessor,
    });
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
}
