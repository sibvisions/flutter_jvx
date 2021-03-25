import 'package:flutterclient/src/services/remote/rest/http_client.dart';

import 'remote_data_source.dart';
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

class RemoteDataSourceImpl implements RemoteDataSource {
  final HttpClient client;

  RemoteDataSourceImpl({required this.client});

  @override
  Future<void> applicationStyle(ApplicationStyleRequest request) {
    // TODO: implement applicationStyle
    throw UnimplementedError();
  }

  @override
  Future<void> change(ChangeRequest request) {
    // TODO: implement change
    throw UnimplementedError();
  }

  @override
  Future<void> closeScreen(CloseScreenRequest request) {
    // TODO: implement closeScreen
    throw UnimplementedError();
  }

  @override
  Future<void> deviceStatus(DeviceStatusRequest request) {
    // TODO: implement deviceStatus
    throw UnimplementedError();
  }

  @override
  Future<void> downloadImages(DownloadImagesRequest request) {
    // TODO: implement downloadImages
    throw UnimplementedError();
  }

  @override
  Future<void> downloadTranslation(DownloadTranslationRequest request) {
    // TODO: implement downloadTranslation
    throw UnimplementedError();
  }

  @override
  Future<void> login(LoginRequest request) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<void> logout(LogoutRequest request) {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<void> menu(MenuRequest request) {
    // TODO: implement menu
    throw UnimplementedError();
  }

  @override
  Future<void> navigation(NavigationRequest request) {
    // TODO: implement navigation
    throw UnimplementedError();
  }

  @override
  Future<void> openScreen(OpenScreenRequest request) {
    // TODO: implement openScreen
    throw UnimplementedError();
  }

  @override
  Future<void> pressButton(PressButtonRequest request) {
    // TODO: implement pressButton
    throw UnimplementedError();
  }

  @override
  Future<void> setComponentValue(SetComponentValueRequest request) {
    // TODO: implement setComponentValue
    throw UnimplementedError();
  }

  @override
  Future<void> startup(StartupRequest request) {
    // TODO: implement startup
    throw UnimplementedError();
  }

  @override
  Future<void> tabClose(TabCloseRequest request) {
    // TODO: implement tabClose
    throw UnimplementedError();
  }

  @override
  Future<void> tabSelect(TabSelectRequest request) {
    // TODO: implement tabSelect
    throw UnimplementedError();
  }

  @override
  Future<void> upload(UploadRequest request) {
    // TODO: implement upload
    throw UnimplementedError();
  }
}
