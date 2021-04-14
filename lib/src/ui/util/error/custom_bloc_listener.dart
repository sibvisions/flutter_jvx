import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterclient/src/models/api/response_objects/application_parameters_response_object.dart';

import '../../../models/api/errors/failure.dart';
import '../../../models/api/response_objects/menu/menu_response_object.dart';
import '../../../models/state/app_state.dart';
import '../../../services/remote/cubit/api_cubit.dart';
import '../../widgets/dialog/loading_indicator_dialog.dart';
import 'error_handler.dart';

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
      listener: (BuildContext context, ApiState state) {
        ModalRoute modalRoute = ModalRoute.of(context)!;

        if (handleLoading && state is ApiLoading) {
          if (state.stop) {
            hideLoading(context);
          } else {
            showLoadingIndicator(context);
          }
        }

        if (handleError &&
            (state is ApiError ||
                (state is ApiResponse && state.hasObject<Failure>())) &&
            modalRoute.isCurrent) {
          if (state is ApiError) {
            ErrorHandler.handleError(state, context);
          } else if (state is ApiResponse) {
            ErrorHandler.handleError(
                ApiError(failure: state.getObjectByType<Failure>()!), context);
          }
        }

        if (state is ApiResponse) {
          if (state.hasObject<MenuResponseObject>()) {
            appState.menuResponseObject =
                state.getObjectByType<MenuResponseObject>()!;
          }

          if (state.hasObject<ApplicationParametersResponseObject>()) {
            appState.parameters.updateFromResponseObject(
                state.getObjectByType<ApplicationParametersResponseObject>()!);
          }
        }

        if (modalRoute.isCurrent ||
            (state is ApiResponse && state.hasDataObject)) {
          listener(context, state);
        }
      },
      child: child,
    );
  }
}
