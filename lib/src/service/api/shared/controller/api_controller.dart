/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:collection';

import '../../../../../flutter_jvx.dart';
import '../../../../model/request/api_startup_request.dart';
import '../api_response_names.dart';
import '../i_controller.dart';
import '../i_response_processor.dart';
import '../processor/application_meta_data_processor.dart';
import '../processor/application_parameters_processor.dart';
import '../processor/application_settings_processor.dart';
import '../processor/authentication_data_processor.dart';
import '../processor/bad_client_processor.dart';
import '../processor/close_content_processor.dart';
import '../processor/close_frame_processor.dart';
import '../processor/close_screen_processor.dart';
import '../processor/content_processor.dart';
import '../processor/dal_data_provider_changed_processor.dart';
import '../processor/dal_fetch_processor.dart';
import '../processor/dal_meta_data_processor.dart';
import '../processor/device_status_processor.dart';
import '../processor/download_action_processor.dart';
import '../processor/download_images_processor.dart';
import '../processor/download_processor.dart';
import '../processor/download_style_processor.dart';
import '../processor/download_templates_processor.dart';
import '../processor/download_translation_processor.dart';
import '../processor/error_view_processor.dart';
import '../processor/generic_screen_view_processor.dart';
import '../processor/language_processor.dart';
import '../processor/login_view_processor.dart';
import '../processor/menu_view_processor.dart';
import '../processor/message_dialog_processor.dart';
import '../processor/session_expired_processor.dart';
import '../processor/show_document_processor.dart';
import '../processor/upload_action_processor.dart';
import '../processor/user_data_processor.dart';

class ApiController implements IController {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final IResponseProcessor _applicationParameterProcessor = ApplicationParametersProcessor();
  final IResponseProcessor _applicationMetaDataProcessor = ApplicationMetaDataProcessor();
  final IResponseProcessor _applicationSettingsProcessor = ApplicationSettingsProcessor();
  final IResponseProcessor _languageProcessor = LanguageProcessor();
  final IResponseProcessor _menuViewProcessor = MenuViewProcessor();
  final IResponseProcessor _closeScreenProcessor = CloseScreenProcessor();
  final IResponseProcessor _closeFrameProcessor = CloseFrameProcessor();
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
  final IResponseProcessor _downloadTemplatesProcessor = DownloadTemplatesProcessor();
  final IResponseProcessor _downloadTranslationProcessor = DownloadTranslationProcessor();
  final IResponseProcessor _downloadStyleProcessor = DownloadStyleProcessor();
  final IResponseProcessor _messageDialogProcessor = MessageDialogProcessor();
  final IResponseProcessor _deviceStatusProcessor = DeviceStatusProcessor();
  final IResponseProcessor _uploadActionProcessor = UploadActionProcessor();
  final IResponseProcessor _downloadActionProcessor = DownloadActionProcessor();
  final IResponseProcessor _downloadProcessor = DownloadProcessor();
  final IResponseProcessor _badClientProcessor = BadClientProcessor();
  final IResponseProcessor _contentProcessor = ContentProcessor();
  final IResponseProcessor _closeContentProcessor = CloseContentProcessor();
  final IResponseProcessor _showDocumentProcessor = ShowDocumentProcessor();

  /// Maps response names to their processor
  late final HashMap<String, IResponseProcessor> responseToProcessorMap;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiController() {
    responseToProcessorMap = HashMap.of({
      ApiResponseNames.applicationParameters: _applicationParameterProcessor,
      ApiResponseNames.applicationMetaData: _applicationMetaDataProcessor,
      ApiResponseNames.applicationSettings: _applicationSettingsProcessor,
      ApiResponseNames.language: _languageProcessor,
      ApiResponseNames.menu: _menuViewProcessor,
      ApiResponseNames.screenGeneric: _genericScreenViewProcessor,
      ApiResponseNames.closeScreen: _closeScreenProcessor,
      ApiResponseNames.closeFrame: _closeFrameProcessor,
      ApiResponseNames.dalMetaData: _dalMetaDataProcessor,
      ApiResponseNames.dalFetch: _dalFetchProcessor,
      ApiResponseNames.userData: _userDataProcessor,
      ApiResponseNames.login: _loginViewProcessor,
      ApiResponseNames.messageError: _errorViewProcessor,
      ApiResponseNames.sessionExpired: _sessionExpiredProcessor,
      ApiResponseNames.dalDataProviderChanged: _dalDataProviderChangedProcessor,
      ApiResponseNames.authenticationData: _authenticationDataProcessor,
      ApiResponseNames.downloadImages: _downloadImagesProcessor,
      ApiResponseNames.downloadTemplates: _downloadTemplatesProcessor,
      ApiResponseNames.downloadTranslation: _downloadTranslationProcessor,
      ApiResponseNames.messageDialog: _messageDialogProcessor,
      ApiResponseNames.downloadStyle: _downloadStyleProcessor,
      ApiResponseNames.deviceStatus: _deviceStatusProcessor,
      ApiResponseNames.upload: _uploadActionProcessor,
      ApiResponseNames.download: _downloadActionProcessor,
      ApiResponseNames.downloadResponse: _downloadProcessor,
      ApiResponseNames.badClient: _badClientProcessor,
      ApiResponseNames.content: _contentProcessor,
      ApiResponseNames.closeContent: _closeContentProcessor,
      ApiResponseNames.showDocument: _showDocumentProcessor,
    });
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processResponse(ApiInteraction apiInteraction) async {
    List<BaseCommand> commands = [];

    //Special startup handling
    if (apiInteraction.request is ApiStartupRequest) {
      //reset custom startup properties, otherwise same properties will be used for next application start
      //which is not right
      IConfigService().setCustomStartupProperties(null);
    }

    for (ApiResponse response in apiInteraction.responses) {
      IResponseProcessor? processor = responseToProcessorMap[response.name];

      if (processor != null) {
        commands.addAll(await processor.processResponse(response, apiInteraction.request));
      } else {
        throw Exception("Couldn't find response processor for ${response.name}");
      }
    }

    return commands;
  }
}
