import 'package:flutter_client/src/model/api/requests/api_change_password_request.dart';
import 'package:flutter_client/src/model/api/requests/api_close_screen_request.dart';
import 'package:flutter_client/src/model/api/requests/api_close_tab_request.dart';
import 'package:flutter_client/src/model/api/requests/api_delete_record_request.dart';
import 'package:flutter_client/src/model/api/requests/api_device_status_request.dart';
import 'package:flutter_client/src/model/api/requests/api_download_images_request.dart';
import 'package:flutter_client/src/model/api/requests/api_download_style_request.dart';
import 'package:flutter_client/src/model/api/requests/api_download_translation_request.dart';
import 'package:flutter_client/src/model/api/requests/api_fetch_request.dart';
import 'package:flutter_client/src/model/api/requests/api_filter_request.dart';
import 'package:flutter_client/src/model/api/requests/api_insert_record_request.dart';
import 'package:flutter_client/src/model/api/requests/api_login_request.dart';
import 'package:flutter_client/src/model/api/requests/api_logout_request.dart';
import 'package:flutter_client/src/model/api/requests/api_navigation_request.dart';
import 'package:flutter_client/src/model/api/requests/api_open_screen_request.dart';
import 'package:flutter_client/src/model/api/requests/api_open_tab_request.dart';
import 'package:flutter_client/src/model/api/requests/api_press_button_request.dart';
import 'package:flutter_client/src/model/api/requests/api_reset_password_request.dart';
import 'package:flutter_client/src/model/api/requests/api_select_record_request.dart';
import 'package:flutter_client/src/model/api/requests/api_set_value_request.dart';
import 'package:flutter_client/src/model/api/requests/api_set_values_request.dart';
import 'package:flutter_client/src/model/api/requests/api_startup_request.dart';

import 'endpoint_config.dart';
import 'url_config.dart';

/// Config for each requests exact endpoint
class ApiConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Config for the remote server address
  UrlConfig urlConfig;

  /// Config for each individual endpoint
  EndpointConfig endpointConfig;

  /// Map of all remote request mapped to their full uri endpoint in [endpointConfig]
  late Map<Type, Uri Function()> uriMap;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiConfig({required this.urlConfig, required this.endpointConfig}) {
    uriMap = {
      ApiStartUpRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.startup),
      ApiLoginRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.login),
      ApiCloseTabRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.closeTab),
      ApiDeviceStatusRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.deviceStatus),
      ApiOpenScreenRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.openScreen),
      ApiOpenTabRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.openTab),
      ApiPressButtonRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.pressButton),
      ApiSetValueRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.setValue),
      ApiSetValuesRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.setValues),
      ApiChangePasswordRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.changePassword),
      ApiResetPasswordRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.resetPassword),
      ApiNavigationRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.navigation),
      ApiFetchRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.fetch),
      ApiLogoutRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.logout),
      ApiFilterRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.filter),
      ApiInsertRecordRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.insertRecord),
      ApiSelectRecordRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.selectRecord),
      ApiCloseScreenRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.closeScreen),
      ApiDeleteRecordRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.deleteRecord),
      ApiDownloadImagesRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.download),
      ApiDownloadTranslationRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.download),
      ApiDownloadStyleRequest: () => Uri.parse(urlConfig.getBasePath() + endpointConfig.download),
    };
  }
}
