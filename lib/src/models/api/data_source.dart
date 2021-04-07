import 'package:flutterclient/src/models/api/requests/data/data_request.dart';
import 'package:flutterclient/src/models/api/requests/download_request.dart';
import 'package:flutterclient/src/services/remote/cubit/api_cubit.dart';

import 'requests/application_style_request.dart';
import 'requests/change_request.dart';
import 'requests/close_screen_request.dart';
import 'requests/device_status_request.dart';
import 'requests/download_images_request.dart';
import 'requests/download_translation_request.dart';
import 'requests/login_request.dart';
import 'requests/logout_request.dart';
import 'requests/menu_request.dart';
import 'requests/navigation_request.dart';
import 'requests/open_screen_request.dart';
import 'requests/press_button_request.dart';
import 'requests/set_component_value.dart';
import 'requests/startup_request.dart';
import 'requests/tab_close_request.dart';
import 'requests/tab_select_request.dart';
import 'requests/upload_request.dart';

abstract class DataSource {
  Future<ApiState> startup(StartupRequest request);
  Future<ApiState> applicationStyle(ApplicationStyleRequest request);
  Future<ApiState> downloadTranslation(DownloadTranslationRequest request);
  Future<ApiState> downloadImages(DownloadImagesRequest request);
  Future<ApiState> download(DownloadRequest request);
  Future<ApiState> login(LoginRequest request);
  Future<ApiState> logout(LogoutRequest request);
  Future<ApiState> change(ChangeRequest request);
  Future<ApiState> closeScreen(CloseScreenRequest request);
  Future<ApiState> deviceStatus(DeviceStatusRequest request);
  Future<ApiState> menu(MenuRequest request);
  Future<ApiState> navigation(NavigationRequest request);
  Future<ApiState> openScreen(OpenScreenRequest request);
  Future<ApiState> pressButton(PressButtonRequest request);
  Future<ApiState> setComponentValue(SetComponentValueRequest request);
  Future<ApiState> tabClose(TabCloseRequest request);
  Future<ApiState> tabSelect(TabSelectRequest request);
  Future<ApiState> upload(UploadRequest request);
  Future<ApiState> data(DataRequest request);
}
