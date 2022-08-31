import '../../request/api_change_password_request.dart';
import '../../request/api_close_frame_request.dart';
import '../../request/api_close_screen_request.dart';
import '../../request/api_close_tab_request.dart';
import '../../request/api_delete_record_request.dart';
import '../../request/api_device_status_request.dart';
import '../../request/api_download_images_request.dart';
import '../../request/api_download_translation_request.dart';
import '../../request/api_fetch_request.dart';
import '../../request/api_insert_record_request.dart';
import '../../request/api_login_request.dart';
import '../../request/api_logout_request.dart';
import '../../request/api_menu_request.dart';
import '../../request/api_navigation_request.dart';
import '../../request/api_open_screen_request.dart';
import '../../request/api_press_button_request.dart';
import '../../request/api_reset_password_request.dart';
import '../../request/api_select_record_request.dart';
import '../../request/api_set_value_request.dart';
import '../../request/api_set_values_request.dart';
import '../../request/api_startup_request.dart';
import '../../request/i_api_request.dart';

/// Config for all endpoints for all [IApiRequest]s
class EndpointConfig {
  /// For [ApiStartUpRequest]
  final String startup;

  /// For [ApiLoginRequest]
  final String login;

  /// For [ApiOpenScreenRequest]
  final String openScreen;

  /// For [ApiDeviceStatusRequest]
  final String deviceStatus;

  /// For [ApiPressButtonRequest]
  final String pressButton;

  /// For [ApiSetValueRequest]
  final String setValue;

  /// For [ApiSetValuesRequest]
  final String setValues;

  /// For [ApiDownloadImagesRequest] & [ApiDownloadTranslationRequest]
  final String download;

  /// For [ApiCloseTabRequest]
  final String closeTab;

  /// For [ApiOpenTabRequest]
  final String openTab;

  /// For [ApiChangePasswordRequest]
  final String changePassword;

  /// For [ApiResetPasswordRequest]
  final String resetPassword;

  /// For [ApiNavigationRequest]
  final String navigation;

  /// For [ApiFetchRequest]
  final String fetch;

  /// For [ApiLogoutRequest]
  final String logout;

  /// For [ApiFilterRequest]
  final String filter;

  /// For [ApiInsertRecordRequest]
  final String insertRecord;

  /// For [ApiSelectRecordRequest]
  final String selectRecord;

  /// For [ApiCloseScreenRequest]
  final String closeScreen;

  /// Fot [ApiDeleteRecordRequest]
  final String deleteRecord;

  /// For [ApiCloseFrameRequest]
  final String closeFrame;

  /// For [ApiMenuRequest]
  final String menu;

  const EndpointConfig({
    required this.startup,
    required this.login,
    required this.openScreen,
    required this.deviceStatus,
    required this.pressButton,
    required this.setValue,
    required this.setValues,
    required this.download,
    required this.closeTab,
    required this.openTab,
    required this.changePassword,
    required this.resetPassword,
    required this.navigation,
    required this.menu,
    required this.fetch,
    required this.logout,
    required this.filter,
    required this.insertRecord,
    required this.selectRecord,
    required this.closeScreen,
    required this.deleteRecord,
    required this.closeFrame,
  });
}
