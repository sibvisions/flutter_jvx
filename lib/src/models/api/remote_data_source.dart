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

abstract class RemoteDataSource {
  Future<void> startup(StartupRequest request);
  Future<void> applicationStyle(ApplicationStyleRequest request);
  Future<void> downloadTranslation(DownloadTranslationRequest request);
  Future<void> downloadImages(DownloadImagesRequest request);
  Future<void> login(LoginRequest request);
  Future<void> logout(LogoutRequest request);
  Future<void> change(ChangeRequest request);
  Future<void> closeScreen(CloseScreenRequest request);
  Future<void> deviceStatus(DeviceStatusRequest request);
  Future<void> menu(MenuRequest request);
  Future<void> navigation(NavigationRequest request);
  Future<void> openScreen(OpenScreenRequest request);
  Future<void> pressButton(PressButtonRequest request);
  Future<void> setComponentValue(SetComponentValueRequest request);
  Future<void> tabClose(TabCloseRequest request);
  Future<void> tabSelect(TabSelectRequest request);
  Future<void> upload(UploadRequest request);
}
