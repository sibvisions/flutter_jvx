import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/api/request/close_screen.dart';
import '../logic/bloc/api_bloc.dart';
import '../model/api/request/reload.dart';
import '../model/api/request/request.dart';
import '../model/api/request/open_screen.dart';
import '../model/so_action.dart' as act;
import 'globals.dart' as globals;

class ApplicationApi {
  BuildContext _context;

  ApplicationApi(this._context);

  reload() {
    BlocProvider.of<ApiBloc>(_context)
        .dispatch(Reload(requestType: RequestType.RELOAD));
  }

  openScreen(String componentId, String label) {
    act.SoAction action = act.SoAction(componentId: componentId, label: label);

    OpenScreen openScreen = OpenScreen(
        action: action,
        clientId: globals.clientId,
        manualClose: false,
        requestType: RequestType.OPEN_SCREEN);

    BlocProvider.of<ApiBloc>(_context).dispatch(openScreen);
  }

  closeScreen(String componentId) {
    CloseScreen closeScreen = CloseScreen(
        clientId: globals.clientId,
        componentId: componentId,
        requestType: RequestType.CLOSE_SCREEN);

    BlocProvider.of<ApiBloc>(_context).dispatch(closeScreen);
  }

  dispatch(Request request) {
    BlocProvider.of<ApiBloc>(_context).dispatch(request);
  }

  BuildContext get context {
    return _context;
  }
}
