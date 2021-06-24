import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:flutterclient/src/models/api/requests/change_password_request.dart';
import 'package:flutterclient/src/util/app/state/state_helper.dart';

import '../../models/state/routes/routes.dart';
import '../../models/api/errors/failure.dart';
import '../../models/api/response_objects/application_parameters_response_object.dart';
import '../../models/api/response_objects/menu/menu_response_object.dart';
import '../../models/api/response_objects/restart_response_object.dart';
import '../../models/api/response_objects/user_data_response_object.dart';
import '../../models/state/app_state.dart';
import '../../services/remote/cubit/api_cubit.dart';
import '../widgets/dialog/loading_indicator_dialog.dart';
import '../widgets/dialog/show_restart_dialog.dart';
import 'error/error_handler.dart';

class CustomCubitListener extends StatelessWidget {
  final Function(BuildContext, ApiState) listener;
  final ApiCubit bloc;
  final Widget child;
  final bool handleError;
  final bool handleLoading;
  final AppState appState;

  const CustomCubitListener({
    Key? key,
    required this.listener,
    required this.bloc,
    required this.child,
    required this.appState,
    this.handleError = true,
    this.handleLoading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApiCubit, ApiState>(
      bloc: bloc,
      listener: (BuildContext context, ApiState state) async {
        ModalRoute modalRoute = ModalRoute.of(context)!;

        if (handleLoading && state is ApiLoading) {
          if (state.stop) {
            hideLoading(context);
          } else {
            showLoadingIndicator(context);
          }
        }

        if (handleError && !appState.showsError && state is ApiError) {
          appState.showsError = true;
          await ErrorHandler.handleResponse(context, state);
          appState.showsError = false;
        }

        if (state is ApiResponse) {
          StateHelper.updateAppStateAndLocalDataWithResponse(
              appState, SharedPreferencesProvider.of(context)!.manager, state);

          if (state.hasObject<RestartResponseObject>()) {
            showRestartDialog(
                context, state.getObjectByType<RestartResponseObject>()!.info);
          }
        }

        if (((modalRoute.isCurrent ||
                    modalRoute.settings.name == Routes.openScreen) ||
                (state is ApiResponse && state.hasObject<Failure>())) &&
            (state is ApiResponse && !(state.request is ChangePasswordRequest)))
          listener(context, state);

        if (state is ApiResponse && state.hasObject<Failure>()) {
          appState.showsError = true;
          await ErrorHandler.handleResponse(context, state);
          appState.showsError = false;
        }
      },
      child: child,
    );
  }
}
