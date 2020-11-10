import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/api/request.dart';
import '../../../models/api/request/close_screen.dart';
import '../../../models/api/request/menu.dart';
import '../../../models/api/request/open_screen.dart';
import '../../../models/api/request/reload.dart';
import '../../../models/api/response.dart';
import '../../../models/api/so_action.dart';
import '../../../services/remote/bloc/api_bloc.dart';
import '../../../ui/widgets/util/app_state_provider.dart';

class ApplicationApi {
  List<void Function(Response response)> listeners =
      <void Function(Response response)>[];

  BuildContext _context;

  ApplicationApi(this._context);

  addListener(void Function(Response response) onState) {
    if (!listeners.contains(onState)) {
      listeners.add(onState);
      state(
          onListen: (StreamSubscription<Response> response) =>
              response.onData((data) {
                onState(data);
              }));
    }
  }

  reload() {
    BlocProvider.of<ApiBloc>(_context)
        .add(Reload(requestType: RequestType.RELOAD));
  }

  openScreen(String componentId, String label) {
    SoAction action = SoAction(componentId: componentId, label: label);

    OpenScreen openScreen = OpenScreen(
        action: action,
        clientId: AppStateProvider.of(this._context).appState.clientId,
        manualClose: false,
        requestType: RequestType.OPEN_SCREEN);

    BlocProvider.of<ApiBloc>(_context).add(openScreen);
  }

  closeScreen(String componentId) {
    CloseScreen closeScreen = CloseScreen(
        clientId: AppStateProvider.of(this._context).appState.clientId,
        componentId: componentId,
        requestType: RequestType.CLOSE_SCREEN);

    BlocProvider.of<ApiBloc>(_context).add(closeScreen);
  }

  menu() {
    Menu menu = Menu(AppStateProvider.of(this._context).appState.clientId);

    BlocProvider.of<ApiBloc>(_context).add(menu);
  }

  dispatch(Request request) {
    BlocProvider.of<ApiBloc>(_context).add(request);
  }

  BuildContext get context {
    return _context;
  }

  set context(BuildContext context) {
    if (context != null) {
      _context = context;
    }
  }

  Response state(
      {void Function(StreamSubscription<Response>) onListen,
      void Function(StreamSubscription<Response>) onCancel}) {
    BlocProvider.of<ApiBloc>(_context)
        .asBroadcastStream(onListen: onListen, onCancel: onCancel);
  }
}
