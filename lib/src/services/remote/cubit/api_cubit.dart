import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:meta/meta.dart';

import '../../../models/api/errors/failure.dart';
import '../../../models/api/request.dart';
import '../../../models/api/requests/application_style_request.dart';
import '../../../models/api/requests/change_request.dart';
import '../../../models/api/requests/close_screen_request.dart';
import '../../../models/api/requests/data/data_request.dart';
import '../../../models/api/requests/device_status_request.dart';
import '../../../models/api/requests/download_images_request.dart';
import '../../../models/api/requests/download_request.dart';
import '../../../models/api/requests/download_translation_request.dart';
import '../../../models/api/requests/login_request.dart';
import '../../../models/api/requests/logout_request.dart';
import '../../../models/api/requests/menu_request.dart';
import '../../../models/api/requests/navigation_request.dart';
import '../../../models/api/requests/open_screen_request.dart';
import '../../../models/api/requests/press_button_request.dart';
import '../../../models/api/requests/set_component_value.dart';
import '../../../models/api/requests/startup_request.dart';
import '../../../models/api/requests/tab_close_request.dart';
import '../../../models/api/requests/tab_select_request.dart';
import '../../../models/api/requests/upload_request.dart';
import '../../../models/api/response_object.dart';
import '../../../models/api/response_objects/application_meta_data_response_object.dart';
import '../../../models/api/response_objects/application_parameters_response_object.dart';
import '../../../models/api/response_objects/application_style/application_style_response_object.dart';
import '../../../models/api/response_objects/authentication_data_response_object.dart';
import '../../../models/api/response_objects/close_screen_action_response_object.dart';
import '../../../models/api/response_objects/device_status_response_object.dart';
import '../../../models/api/response_objects/download_action_response_object.dart';
import '../../../models/api/response_objects/language_response_object.dart';
import '../../../models/api/response_objects/login_response_object.dart';
import '../../../models/api/response_objects/menu/menu_response_object.dart';
import '../../../models/api/response_objects/response_data/data/data_book.dart';
import '../../../models/api/response_objects/response_data/data/dataprovider_changed.dart';
import '../../../models/api/response_objects/response_data/meta_data/data_book_meta_data.dart';
import '../../../models/api/response_objects/response_data/screen_generic_response_object.dart';
import '../../../models/api/response_objects/restart_response_object.dart';
import '../../../models/api/response_objects/show_document_response_object.dart';
import '../../../models/api/response_objects/upload_action_response_object.dart';
import '../../../models/api/response_objects/user_data_response_object.dart';
import '../../../models/state/app_state.dart';
import '../../local/shared_preferences/shared_preferences_manager.dart';
import '../network_info/network_info.dart';

part 'api_state.dart';

class ApiCubit extends Cubit<ApiState> {
  final ApiRepository repository;
  final AppState appState;
  final SharedPreferencesManager manager;
  final NetworkInfo networkInfo;

  ApiCubit(
      {required this.repository,
      required this.appState,
      required this.manager,
      required this.networkInfo})
      : super(ApiInitial());

  factory ApiCubit.withDependencies() {
    return ApiCubit(
        repository: sl(), appState: sl(), manager: sl(), networkInfo: sl());
  }

  Future<void> startup(StartupRequest request) async {
    emit(await repository.startup(request));
  }

  Future<void> applicationStyle(ApplicationStyleRequest request) async {
    emit(await repository.applicationStyle(request));
  }

  Future<void> downloadImages(DownloadImagesRequest request) async {
    emit(await repository.downloadImages(request));
  }

  Future<void> downloadTranslation(DownloadTranslationRequest request) async {
    emit(await repository.downloadTranslation(request));
  }

  Future<void> login(LoginRequest request) async {
    emit(ApiLoading());

    final apiState = await repository.login(request);

    emit(ApiLoading(stop: true));
    emit(apiState);
  }

  Future<void> logout(LogoutRequest request) async {
    emit(await repository.logout(request));
  }

  Future<void> openScreen(OpenScreenRequest request) async {
    emit(ApiLoading());

    final apiState = await repository.openScreen(request);

    emit(ApiLoading(stop: true));

    emit(apiState);
  }

  Future<void> navigation(NavigationRequest request) async {
    emit(ApiLoading());

    final apiState = await repository.navigation(request);

    emit(ApiLoading(stop: true));

    emit(apiState);
  }

  Future<void> pressButton(PressButtonRequest request) async {
    ApiState apiState = await repository.pressButton(request);

    emit(apiState);
  }

  Future<ApiState> data(DataRequest request) async {
    List<ApiState> states = await repository.data(request);

    for (final state in states) {
      emit(state);
    }

    return states.first;
  }

  Future<void> change(ChangeRequest request) async {
    emit(await repository.change(request));
  }

  Future<void> closeScreen(CloseScreenRequest request) async {
    emit(await repository.closeScreen(request));
  }

  Future<void> deviceStatus(DeviceStatusRequest request) async {
    emit(ApiLoading());

    final response = await repository.deviceStatus(request);

    emit(ApiLoading(stop: true));

    emit(response);
  }

  Future<void> menu(MenuRequest request) async {
    emit(await repository.menu(request));
  }

  Future<void> setComponentValue(SetComponentValueRequest request) async {
    emit(await repository.setComponentValue(request));
  }

  Future<void> tabClose(TabCloseRequest request) async {
    emit(await repository.tabClose(request));
  }

  Future<void> tabSelect(TabSelectRequest request) async {
    emit(await repository.tabSelect(request));
  }

  Future<void> upload(UploadRequest request) async {
    emit(await repository.upload(request));
  }

  Future<void> download(DownloadRequest request) async {
    emit(await repository.download(request));
  }
}
