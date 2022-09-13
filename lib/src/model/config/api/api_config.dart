import '../../../../config/config_generator.dart';
import '../../../../config/server_config.dart';
import '../../../../custom/app_manager.dart';
import '../../request/api_change_password_request.dart';
import '../../request/api_close_frame_request.dart';
import '../../request/api_close_screen_request.dart';
import '../../request/api_close_tab_request.dart';
import '../../request/api_delete_record_request.dart';
import '../../request/api_device_status_request.dart';
import '../../request/api_download_images_request.dart';
import '../../request/api_download_request.dart';
import '../../request/api_download_style_request.dart';
import '../../request/api_download_translation_request.dart';
import '../../request/api_fetch_request.dart';
import '../../request/api_filter_request.dart';
import '../../request/api_insert_record_request.dart';
import '../../request/api_login_request.dart';
import '../../request/api_logout_request.dart';
import '../../request/api_navigation_request.dart';
import '../../request/api_open_screen_request.dart';
import '../../request/api_open_tab_request.dart';
import '../../request/api_press_button_request.dart';
import '../../request/api_reload_menu_request.dart';
import '../../request/api_reset_password_request.dart';
import '../../request/api_select_record_request.dart';
import '../../request/api_set_value_request.dart';
import '../../request/api_set_values_request.dart';
import '../../request/api_startup_request.dart';
import '../../request/api_upload_request.dart';
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
  late Map<Type, Uri Function(IApiRequest pRequest)> uriMap;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiConfig({required this.serverConfig, EndpointConfig? endpointConfig})
      : endpointConfig = endpointConfig ?? ConfigGenerator.generateFixedEndpoints() {
    uriMap = {
      ApiStartUpRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.startup),
      ApiLoginRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.login),
      ApiCloseTabRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.closeTab),
      ApiDeviceStatusRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.deviceStatus),
      ApiOpenScreenRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.openScreen),
      ApiOpenTabRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.openTab),
      ApiPressButtonRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.pressButton),
      ApiSetValueRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.setValue),
      ApiSetValuesRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.setValues),
      ApiChangePasswordRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.changePassword),
      ApiResetPasswordRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.resetPassword),
      ApiNavigationRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.navigation),
      ApiReloadMenuRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.menu),
      ApiFetchRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.fetch),
      ApiLogoutRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.logout),
      ApiFilterRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.filter),
      ApiInsertRecordRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.insertRecord),
      ApiSelectRecordRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.selectRecord),
      ApiCloseScreenRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.closeScreen),
      ApiDeleteRecordRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.deleteRecord),
      ApiDownloadImagesRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.download),
      ApiDownloadTranslationRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.download),
      ApiDownloadStyleRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.download),
      ApiCloseFrameRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.closeFrame),
      ApiUploadRequest: (_) => Uri.parse(serverConfig.baseUrl! + this.endpointConfig.upload),
      ApiDownloadRequest: (pRequest) => Uri.parse((pRequest as ApiDownloadRequest).url),
    };
  }
}
