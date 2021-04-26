import 'package:flutter/material.dart';

import '../../../../injection_container.dart';
import '../../../models/api/requests/close_screen_request.dart';
import '../../../models/api/requests/menu_request.dart';
import '../../../models/api/requests/open_screen_request.dart';
import '../../../services/remote/cubit/api_cubit.dart';
import '../../../ui/util/inherited_widgets/app_state_provider.dart';

class ApplicationApi {
  List<void Function(ApiResponse response)> listeners =
      <void Function(ApiResponse response)>[];

  BuildContext _context;

  ApplicationApi(this._context);

  addListener(void Function(ApiState response) onState) {
    if (!listeners.contains(onState)) {
      listeners.add(onState);
      sl<ApiCubit>().stream.listen(onState);
    }
  }

  removeListener(void Function(ApiState response) onState) {
    if (listeners.contains(onState)) {
      listeners.remove(onState);
    }
  }

  openScreen(String componentId, String label) {
    OpenScreenRequest request = OpenScreenRequest(
        clientId: AppStateProvider.of(_context)!
            .appState
            .applicationMetaData!
            .clientId,
        componentId: componentId,
        manualClose: false);

    sl<ApiCubit>().openScreen(request);
  }

  closeScreen(String componentId) {
    CloseScreenRequest request = CloseScreenRequest(
        componentId: componentId,
        clientId: AppStateProvider.of(_context)!
            .appState
            .applicationMetaData!
            .clientId);

    sl<ApiCubit>().closeScreen(request);
  }

  menu() {
    MenuRequest request = MenuRequest(
        clientId: AppStateProvider.of(context)!
            .appState
            .applicationMetaData!
            .clientId);

    sl<ApiCubit>().menu(request);
  }

  BuildContext get context {
    return _context;
  }

  set context(BuildContext? context) {
    if (context != null) _context = context;
  }
}
