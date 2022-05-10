import 'package:flutter_client/src/model/api/requests/api_change_password_request.dart';
import 'package:flutter_client/src/model/api/requests/api_close_tab_request.dart';
import 'package:flutter_client/src/model/api/requests/api_device_status_request.dart';
import 'package:flutter_client/src/model/api/requests/api_download_images_request.dart';
import 'package:flutter_client/src/model/api/requests/api_fetch_request.dart';
import 'package:flutter_client/src/model/api/requests/api_insert_record_request.dart';
import 'package:flutter_client/src/model/api/requests/api_login_request.dart';
import 'package:flutter_client/src/model/api/requests/api_logout_request.dart';
import 'package:flutter_client/src/model/api/requests/api_navigation_request.dart';
import 'package:flutter_client/src/model/api/requests/api_open_screen_request.dart';
import 'package:flutter_client/src/model/api/requests/api_press_button_request.dart';
import 'package:flutter_client/src/model/api/requests/api_reset_password_request.dart';
import 'package:flutter_client/src/model/api/requests/api_set_value_request.dart';
import 'package:flutter_client/src/model/api/requests/api_set_values_request.dart';
import 'package:flutter_client/src/model/api/requests/api_startup_request.dart';
import 'package:flutter_client/src/model/api/requests/i_api_request.dart';

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

  /// For [ApiDownloadImagesRequest]
  final String downloadImages;

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

  EndpointConfig({
    required this.startup,
    required this.login,
    required this.openScreen,
    required this.deviceStatus,
    required this.pressButton,
    required this.setValue,
    required this.setValues,
    required this.downloadImages,
    required this.closeTab,
    required this.openTab,
    required this.changePassword,
    required this.resetPassword,
    required this.navigation,
    required this.fetch,
    required this.logout,
    required this.filter,
    required this.insertRecord,
  });
}
