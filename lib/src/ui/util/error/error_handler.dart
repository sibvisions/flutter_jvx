import 'package:flutter/material.dart';

import '../../../models/state/routes/routes.dart';
import '../../../services/remote/cubit/api_cubit.dart';
import '../../../util/app/text_utils.dart';
import '../../widgets/dialog/show_error_dialog.dart';
import '../../widgets/dialog/show_go_to_settings_dialog.dart';
import '../../widgets/dialog/show_session_expired_dialog.dart';

class ErrorHandler {
  static const String sessionExpired = 'message.sessionexpired';
  static const String messageError = 'message.error';
  static const String serverError = 'server.error';
  static const String connectionError = 'connection.error';
  static const String timeoutError = 'timeout.error';
  static const String internetError = 'internet.error';
  static const String offlineError = 'offline.error';

  static Future<void> handleError(ApiError error, BuildContext context) async {
    TextUtils.unfocusCurrentTextfield(context);

    if (error.failure.name == sessionExpired) {
      showSessionExpiredDialog(context, error);
    } else if (error.failure.name == messageError) {
      if (ModalRoute.of(context)!.settings.name == Routes.startup) {
        showGoToSettingsDialog(context, error);
      } else {
        showErrorDialog(context, error);
      }
    } else if (error.failure.name == serverError) {
      showGoToSettingsDialog(context, error);
    } else if (error.failure.name == connectionError) {
      showGoToSettingsDialog(context, error);
    } else if (error.failure.name == timeoutError) {
      showGoToSettingsDialog(context, error);
    } else if (error.failure.name == internetError) {
      showGoToSettingsDialog(context, error);
    } else if (error.failure.name == offlineError) {
      showGoToSettingsDialog(context, error);
    } else {
      showGoToSettingsDialog(context, error);
    }
  }
}
