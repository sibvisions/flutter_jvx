import 'package:flutter/material.dart';

import '../../../../models/api/requests/login_request.dart';
import '../../../../models/api/response_objects/menu/menu_response_object.dart';
import '../../../../models/api/response_objects/response_data/screen_generic_response_object.dart';
import '../../../../models/api/response_objects/user_data_response_object.dart';
import '../../../../models/state/app_state.dart';
import '../../../../models/state/routes/arguments/menu_page_arguments.dart';
import '../../../../models/state/routes/routes.dart';
import '../../../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../../../services/remote/cubit/api_cubit.dart';
import '../../../util/custom_cubit_listener.dart';
import 'login_background.dart';
import 'login_card.dart';
import 'login_widgets.dart';

class LoginPageWidget extends StatefulWidget {
  final AppState appState;
  final SharedPreferencesManager manager;
  final String? lastUsername;
  final LoginMode loginMode;

  const LoginPageWidget(
      {Key? key,
      required this.appState,
      required this.manager,
      required this.loginMode,
      this.lastUsername})
      : super(key: key);

  @override
  _LoginPageWidgetState createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  bool colorsInverted = false;
  ApiResponse? response;

  late ApiCubit cubit;

  @override
  void initState() {
    colorsInverted = widget.appState.appConfig!.loginColorsInverted;

    super.initState();

    cubit = ApiCubit.withDependencies();
  }

  @override
  void dispose() {
    cubit.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          return true;
        }

        return false;
      },
      child: Scaffold(
        backgroundColor:
            colorsInverted ? Theme.of(context).primaryColor : Colors.white,
        body: CustomCubitListener(
            appState: widget.appState,
            handleLoading: true,
            handleError: true,
            bloc: cubit,
            listener: (context, state) {
              if (state is ApiResponse) {
                if (state.request is LoginRequest &&
                    state.hasObject<MenuResponseObject>()) {
                  if (state.hasObject<ScreenGenericResponseObject>()) {
                    response = state;
                  }

                  if (state.hasObject<UserDataResponseObject>()) {
                    UserDataResponseObject userData =
                        state.getObjectByType<UserDataResponseObject>()!;
                    widget.appState.userData = userData;
                    widget.manager.userData = userData;
                  }

                  Navigator.of(context).pushReplacementNamed(Routes.menu,
                      arguments: MenuPageArguments(
                          menuItems: state
                              .getObjectByType<MenuResponseObject>()!
                              .entries,
                          listMenuItemsInDrawer: true,
                          response: response));
                }
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                LoginBackground(
                  appState: widget.appState,
                  colorsInverted: colorsInverted,
                ),
                LoginWidgets(
                  username: widget.lastUsername ?? '',
                  appState: widget.appState,
                  cubit: cubit,
                  loginMode: widget.loginMode,
                )
              ],
            )),
      ),
    );
  }
}
