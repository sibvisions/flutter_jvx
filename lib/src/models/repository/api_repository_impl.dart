import 'package:flutterclient/src/models/api/remote_data_source.dart';
import 'package:flutterclient/src/services/remote/rest/http_client.dart';

import '../../services/remote/cubit/api_cubit.dart';
import '../api/requests/application_style_request.dart';
import '../api/requests/change_request.dart';
import '../api/requests/close_screen_request.dart';
import '../api/requests/device_status_request.dart';
import '../api/requests/download_images_request.dart';
import '../api/requests/download_translation_request.dart';
import '../api/requests/login_request.dart';
import '../api/requests/logout_request.dart';
import '../api/requests/menu_request.dart';
import '../api/requests/navigation_request.dart';
import '../api/requests/open_screen_request.dart';
import '../api/requests/press_button_request.dart';
import '../api/requests/set_component_value.dart';
import '../api/requests/startup_request.dart';
import '../api/requests/tab_close_request.dart';
import '../api/requests/tab_select_request.dart';
import '../api/requests/upload_request.dart';
import 'api_repository.dart';

class ApiRepositoryImpl implements ApiRepository {
  final RemoteDataSource remoteDataSource;

  ApiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiState> applicationStyle(ApplicationStyleRequest request) {
    // TODO: implement applicationStyle
    throw UnimplementedError();
  }

  @override
  Future<ApiState> change(ChangeRequest request) {
    // TODO: implement change
    throw UnimplementedError();
  }

  @override
  Future<ApiState> closeScreen(CloseScreenRequest request) {
    // TODO: implement closeScreen
    throw UnimplementedError();
  }

  @override
  Future<ApiState> deviceStatus(DeviceStatusRequest request) {
    // TODO: implement deviceStatus
    throw UnimplementedError();
  }

  @override
  Future<ApiState> downloadImages(DownloadImagesRequest request) {
    // TODO: implement downloadImages
    throw UnimplementedError();
  }

  @override
  Future<ApiState> downloadTranslation(DownloadTranslationRequest request) {
    // TODO: implement downloadTranslation
    throw UnimplementedError();
  }

  @override
  Future<ApiState> login(LoginRequest request) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<ApiState> logout(LogoutRequest request) {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<ApiState> menu(MenuRequest request) {
    // TODO: implement menu
    throw UnimplementedError();
  }

  @override
  Future<ApiState> navigation(NavigationRequest request) {
    // TODO: implement navigation
    throw UnimplementedError();
  }

  @override
  Future<ApiState> openScreen(OpenScreenRequest request) {
    // TODO: implement openScreen
    throw UnimplementedError();
  }

  @override
  Future<ApiState> pressButton(PressButtonRequest request) {
    // TODO: implement pressButton
    throw UnimplementedError();
  }

  @override
  Future<ApiState> setComponentValue(SetComponentValueRequest request) {
    // TODO: implement setComponentValue
    throw UnimplementedError();
  }

  @override
  Future<ApiState> startup(StartupRequest request) {
    // TODO: implement startup
    throw UnimplementedError();
  }

  @override
  Future<ApiState> tabClose(TabCloseRequest request) {
    // TODO: implement tabClose
    throw UnimplementedError();
  }

  @override
  Future<ApiState> tabSelect(TabSelectRequest request) {
    // TODO: implement tabSelect
    throw UnimplementedError();
  }

  @override
  Future<ApiState> upload(UploadRequest request) {
    // TODO: implement upload
    throw UnimplementedError();
  }
}
