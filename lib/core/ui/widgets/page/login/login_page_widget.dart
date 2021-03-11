import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/core/ui/pages/menu_page.dart';

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
  final AppState appState;

  const LoginPageWidget({Key key, this.lastUsername, @required this.appState})
      : super(key: key);

  @override
  _LoginPageWidgetState createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  @override
  Widget build(BuildContext context) {
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
                widget.appState.username = state.userData.userName;
                widget.appState.displayName = state.userData.displayName;
                widget.appState.profileImage = state.userData.profileImage;
                widget.appState.roles = state.userData.roles;
              }

              Navigator.of(context).pushReplacementNamed(MenuPage.route,
                  arguments: MenuArguments(state.menu.entries, true,
                      state.responseData.screenGeneric != null ? state : null));
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.appState.applicationStyle.loginIcon != null)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(File(
                                '${widget.appState.dir}${widget.appState.applicationStyle.loginIcon}')))),
                  ),
                )
              else
                LoginBackground(widget.appState),
              if (widget.appState.applicationStyle.loginIcon != null)
                Positioned(
                  top: 100,
                  left: 20,
                  right: 20,
                  child: Image.file(File(
                      '${widget.appState.dir}${widget.appState.applicationStyle.loginLogo}')),
                ),
              LoginWidgets(
                appState: widget.appState,
                username: widget.lastUsername,
              )
            ],
          )),
    );
  }
}
