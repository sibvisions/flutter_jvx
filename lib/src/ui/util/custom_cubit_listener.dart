import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../flutterclient.dart';
import '../../models/api/errors/failure.dart';
import '../../models/api/requests/change_password_request.dart';
import '../../models/api/response_objects/restart_response_object.dart';
import '../../models/state/app_state.dart';
import '../../models/state/routes/routes.dart';
import '../../services/remote/cubit/api_cubit.dart';
import '../../util/app/state/state_helper.dart';
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


        if ((state is ApiResponse && state.hasObject<Failure>() && !appState.showsError)
            ||
            (state is ApiError && !appState.showsError)) {
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


      },
      child: child,
    );
  }
}
