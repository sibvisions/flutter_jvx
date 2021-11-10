import 'package:flutter/material.dart';

import '../../../models/api/errors/failure.dart';
import '../../../models/state/routes/routes.dart';
import '../../../services/remote/cubit/api_cubit.dart';
import '../../../util/app/text_utils.dart';
import '../../widgets/dialog/show_error_dialog.dart';
import '../../widgets/dialog/show_go_to_settings_dialog.dart';
import '../../widgets/dialog/show_session_expired_dialog.dart';

class ErrorHandler {
  static const String sessionExpired = 'message.sessionexpired';
  static const String messageError = 'message.error';
  static const String messageInfo = 'message.information';
  static const String serverError = 'server.error';
  static const String connectionError = 'connection.error';
  static const String timeoutError = 'timeout.error';
  static const String internetError = 'internet.error';
  static const String offlineError = 'offline.error';
  static const String cacheError = 'cache.error';

  static Future<void> handleError(ApiError error, BuildContext context) async {
    TextUtils.unfocusCurrentTextfield(context);

    // log('ERROR VIEW RESPONSE: ${error.failure.message}');

    for (final failure in error.failures) {
      if (!failure.silentAbort) {
        if (failure.name == sessionExpired) {
          showSessionExpiredDialog(context, failure);
        } else if (failure.name == messageError) {
          if (ModalRoute.of(context)!.settings.name == Routes.startup) {
            showGoToSettingsDialog(context, failure);
          } else {
            showErrorDialog(context, failure);
          }
        } else if (failure.name == serverError) {
          showGoToSettingsDialog(context, failure);
        } else if (failure.name == connectionError) {
          showGoToSettingsDialog(context, failure);
        } else if (failure.name == timeoutError) {
          showGoToSettingsDialog(context, failure);
        } else if (failure.name == internetError) {
          showGoToSettingsDialog(context, failure);
        } else if (failure.name == offlineError) {
          showGoToSettingsDialog(context, failure);
        } else if (failure.name == cacheError) {
          showErrorDialog(context, failure);
        } else {
          showGoToSettingsDialog(context, failure);
        }
      }
    }
  }

  static Future<void> handleResponse(
      BuildContext context, ApiState state) async {
    if (state is ApiError) {
      await handleError(state, context);
    } else if (state is ApiResponse && state.hasObject<Failure>()) {
      List<Failure> failures = state.getAllObjectsByType<Failure>();

      await handleError(ApiError(failures: failures), context);
    }
  }
}
