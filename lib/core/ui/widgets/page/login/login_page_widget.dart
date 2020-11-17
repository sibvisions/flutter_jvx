import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/api/request.dart';
import '../../../../models/api/response.dart';
import '../../../../models/app/app_state.dart';
import '../../../../models/app/menu_arguments.dart';
import '../../../../services/remote/bloc/api_bloc.dart';
import '../../dialogs/dialogs.dart';
import '../../util/app_state_provider.dart';
import '../../util/error_handling.dart';
import 'login_background.dart';
import 'login_widgets.dart';

class LoginPageWidget extends StatefulWidget {
  final String lastUsername;

  const LoginPageWidget({Key key, this.lastUsername}) : super(key: key);

  @override
  _LoginPageWidgetState createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  @override
  Widget build(BuildContext context) {
    AppState appState = AppStateProvider.of(context).appState;

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          return true;
        }
        return false;
      },
      child: BlocListener<ApiBloc, Response>(
          listener: (context, state) {
            if (state.request.requestType == RequestType.LOADING) {
              showProgress(context);
            }

            if (state.request.requestType != RequestType.LOADING) {
              hideProgress(context);
            }

            if (state.hasError) {
              handleError(state, context);
            }

            if (state != null &&
                state.request.requestType == RequestType.LOGIN &&
                state.menu != null) {
              if (state.userData != null) {
                appState.username = state.userData.userName;
                appState.displayName = state.userData.displayName;
                appState.profileImage = state.userData.profileImage;
                appState.roles = state.userData.roles;
              }

              Navigator.of(context).pushReplacementNamed('/menu',
                  arguments: MenuArguments(state.menu.entries, true,
                      state.responseData.screenGeneric != null ? state : null));
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              LoginBackground(appState),
              LoginWidgets(
                appState: appState,
                username: widget.lastUsername,
              )
            ],
          )),
    );
  }
}
