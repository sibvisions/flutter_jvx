import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/bloc/api_bloc.dart';
import '../model/api/request/reload.dart';
import '../model/api/request/request.dart';
import '../model/api/request/open_screen.dart';
import '../model/action.dart' as act;
import 'globals.dart' as globals;

class AppApi {
  BuildContext _context;

  AppApi(this._context);

  reload() {
    BlocProvider.of<ApiBloc>(_context)
        .dispatch(Reload(requestType: RequestType.RELOAD));
  }

  openScreen(String componentId, String label) {
    act.Action action = act.Action(componentId: componentId, label: label);

    OpenScreen openScreen = OpenScreen(
        action: action,
        clientId: globals.clientId,
        manualClose: false,
        requestType: RequestType.OPEN_SCREEN);

    BlocProvider.of<ApiBloc>(_context).dispatch(openScreen);
  }

  dispatch(Request request){
    BlocProvider.of<ApiBloc>(_context).dispatch(request);
  }

  BuildContext get context{
    return _context;
  }
}
