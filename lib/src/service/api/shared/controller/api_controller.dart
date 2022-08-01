import 'dart:collection';

import '../../../../model/command/base_command.dart';
import '../../../../model/response/api_response.dart';
import '../api_response_names.dart';
import '../i_controller.dart';
import '../i_response_processor.dart';
import '../processor/application_meta_data_processor.dart';
import '../processor/application_parameters_processor.dart';
import '../processor/authentication_data_processor.dart';
import '../processor/close_screen_processor.dart';
import '../processor/dal_data_provider_changed_processor.dart';
import '../processor/dal_fetch_processor.dart';
import '../processor/dal_meta_data_processor.dart';
import '../processor/download_images_processor.dart';
import '../processor/download_style_processor.dart';
import '../processor/download_translation_processor.dart';
import '../processor/error_view_processor.dart';
import '../processor/generic_screen_view_processor.dart';
import '../processor/login_view_processor.dart';
import '../processor/menu_view_processor.dart';
import '../processor/message_dialog_processor.dart';
import '../processor/session_expired_processor.dart';
import '../processor/user_data_processor.dart';

class ApiController implements IController {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final IResponseProcessor _applicationParameterProcessor = ApplicationParametersProcessor();
  final IResponseProcessor _applicationMetaDataProcessor = ApplicationMetaDataProcessor();
  final IResponseProcessor _menuViewProcessor = MenuViewProcessor();
  final IResponseProcessor _closeScreenProcessor = CloseScreenProcessor();
  final IResponseProcessor _genericScreenViewProcessor = GenericScreenViewProcessor();
  final IResponseProcessor _dalMetaDataProcessor = DalMetaDataProcessor();
  final IResponseProcessor _dalFetchProcessor = DalFetchProcessor();
  final IResponseProcessor _userDataProcessor = UserDataProcessor();
  final IResponseProcessor _loginViewProcessor = LoginViewProcessor();
  final IResponseProcessor _errorViewProcessor = ErrorViewProcessor();
  final IResponseProcessor _sessionExpiredProcessor = SessionExpiredProcessor();
  final IResponseProcessor _dalDataProviderChangedProcessor = DalDataProviderChangedProcessor();
  final IResponseProcessor _authenticationDataProcessor = AuthenticationDataProcessor();
  final IResponseProcessor _downloadImagesProcessor = DownloadImagesProcessor();
  final IResponseProcessor _downloadTranslationProcessor = DownloadTranslationProcessor();
  final IResponseProcessor _downloadStyleProcessor = DownloadStyleProcessor();
  final IResponseProcessor _messageDialogProcessor = MessageDialogProcessor();

  /// Maps response names to their processor
  late final HashMap<String, IResponseProcessor> responseToProcessorMap;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiController() {
    responseToProcessorMap = HashMap.from({
      ApiResponseNames.applicationParameters: _applicationParameterProcessor,
      ApiResponseNames.applicationMetaData: _applicationMetaDataProcessor,
      ApiResponseNames.menu: _menuViewProcessor,
      ApiResponseNames.screenGeneric: _genericScreenViewProcessor,
      ApiResponseNames.closeScreen: _closeScreenProcessor,
      ApiResponseNames.dalMetaData: _dalMetaDataProcessor,
      ApiResponseNames.dalFetch: _dalFetchProcessor,
      ApiResponseNames.userData: _userDataProcessor,
      ApiResponseNames.login: _loginViewProcessor,
      ApiResponseNames.error: _errorViewProcessor,
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
      IResponseProcessor? processor = responseToProcessorMap[response.name];

      if (processor != null) {
        commands.addAll(processor.processResponse(pResponse: response));
      } else {
        throw Exception("Couldn't find processor belonging to ${response.name}, add it to the map");
      }
    }

    return commands;
  }
}
