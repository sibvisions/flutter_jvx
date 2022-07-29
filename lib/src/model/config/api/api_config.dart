import '../../../../data/config/config_generator.dart';
import '../../api/requests/api_change_password_request.dart';
import '../../api/requests/api_close_frame_request.dart';
import '../../api/requests/api_close_screen_request.dart';
import '../../api/requests/api_close_tab_request.dart';
import '../../api/requests/api_delete_record_request.dart';
import '../../api/requests/api_device_status_request.dart';
import '../../api/requests/api_download_images_request.dart';
import '../../api/requests/api_download_style_request.dart';
import '../../api/requests/api_download_translation_request.dart';
import '../../api/requests/api_fetch_request.dart';
import '../../api/requests/api_filter_request.dart';
import '../../api/requests/api_insert_record_request.dart';
import '../../api/requests/api_login_request.dart';
import '../../api/requests/api_logout_request.dart';
import '../../api/requests/api_navigation_request.dart';
import '../../api/requests/api_open_screen_request.dart';
import '../../api/requests/api_open_tab_request.dart';
import '../../api/requests/api_press_button_request.dart';
import '../../api/requests/api_reset_password_request.dart';
import '../../api/requests/api_select_record_request.dart';
import '../../api/requests/api_set_value_request.dart';
import '../../api/requests/api_set_values_request.dart';
import '../../api/requests/api_startup_request.dart';
import '../config_file/server_config.dart';
import 'endpoint_config.dart';

/// Config for each requests exact endpoint
class ApiConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Config for the remote server address
  final ServerConfig serverConfig;

  /// Config for each individual endpoint
  final EndpointConfig endpointConfig;

  /// Map of all remote request mapped to their full uri endpoint in [endpointConfig]
  late Map<Type, Uri Function()> uriMap;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiConfig({required this.serverConfig, EndpointConfig? endpointConfig})
      : endpointConfig = endpointConfig ?? ConfigGenerator.generateFixedEndpoints() {
    uriMap = {
      ApiStartUpRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.startup),
      ApiLoginRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.login),
      ApiCloseTabRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.closeTab),
      ApiDeviceStatusRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.deviceStatus),
      ApiOpenScreenRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.openScreen),
      ApiOpenTabRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.openTab),
      ApiPressButtonRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.pressButton),
      ApiSetValueRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.setValue),
      ApiSetValuesRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.setValues),
      ApiChangePasswordRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.changePassword),
      ApiResetPasswordRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.resetPassword),
      ApiNavigationRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.navigation),
      ApiFetchRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.fetch),
      ApiLogoutRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.logout),
      ApiFilterRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.filter),
      ApiInsertRecordRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.insertRecord),
      ApiSelectRecordRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.selectRecord),
      ApiCloseScreenRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.closeScreen),
      ApiDeleteRecordRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.deleteRecord),
      ApiDownloadImagesRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.download),
      ApiDownloadTranslationRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.download),
      ApiDownloadStyleRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.download),
      ApiCloseFrameRequest: () => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.closeFrame),
    };
  }
}
