import 'package:flutter_client/src/model/api/requests/api_change_password_request.dart';
import 'package:flutter_client/src/model/api/requests/api_close_tab_request.dart';
import 'package:flutter_client/src/model/api/requests/api_device_status_request.dart';
import 'package:flutter_client/src/model/api/requests/api_download_images_request.dart';
import 'package:flutter_client/src/model/api/requests/api_login_request.dart';
import 'package:flutter_client/src/model/api/requests/api_open_screen_request.dart';
import 'package:flutter_client/src/model/api/requests/api_open_tab_request.dart';
import 'package:flutter_client/src/model/api/requests/api_press_button_request.dart';
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
  final UrlConfig urlConfig;
  /// Config for each individual endpoint
  final EndpointConfig endpointConfig;
  /// Map of all remote request mapped to their full uri endpoint in [endpointConfig]
  late final Map<Type, Uri> uriMap;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiConfig({
    required this.urlConfig,
    required this.endpointConfig
  }) {
    uriMap = {
      ApiStartUpRequest : Uri.parse(urlConfig.getBasePath() + endpointConfig.startup),
      ApiLoginRequest : Uri.parse(urlConfig.getBasePath() + endpointConfig.login),
      ApiCloseTabRequest : Uri.parse(urlConfig.getBasePath() + endpointConfig.closeTab),
      ApiDeviceStatusRequest : Uri.parse(urlConfig.getBasePath() + endpointConfig.deviceStatus),
      ApiOpenScreenRequest : Uri.parse(urlConfig.getBasePath() + endpointConfig.openScreen),
      ApiDownloadImagesRequest : Uri.parse(urlConfig.getBasePath() + endpointConfig.downloadImages),
      ApiOpenTabRequest : Uri.parse(urlConfig.getBasePath() + endpointConfig.openTab),
      ApiPressButtonRequest : Uri.parse(urlConfig.getBasePath() + endpointConfig.pressButton),
      ApiSetValueRequest : Uri.parse(urlConfig.getBasePath() + endpointConfig.setValue),
      ApiSetValuesRequest : Uri.parse(urlConfig.getBasePath() + endpointConfig.setValues),
      ApiChangePasswordRequest : Uri.parse(urlConfig.getBasePath() + endpointConfig.changePassword)
    };
  }

}
