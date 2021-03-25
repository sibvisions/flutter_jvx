import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/errors/failure.dart';
import 'package:flutterclient/src/services/remote/cubit/api_cubit.dart';
import 'package:flutterclient/src/ui/widgets/dialog/show_error_dialog.dart';
import 'package:flutterclient/src/ui/widgets/dialog/show_go_to_settings_dialog.dart';
import 'package:flutterclient/src/ui/widgets/dialog/show_session_expired_dialog.dart';
import 'package:flutterclient/src/util/app/text_utils.dart';

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
      showErrorDialog(context, error);
    } else if (error.failure.name == serverError) {
      showGoToSettingsDialog(context, error);
    } else if (error.failure.name == connectionError) {
      showGoToSettingsDialog(context, error);
    } else if (error.failure.name == timeoutError) {
      showGoToSettingsDialog(context, error);
    } else if (error.failure.name == internetError) {
      showErrorDialog(context, error);
    } else if (error.failure.name == offlineError) {
      showGoToSettingsDialog(context, error);
    } else {
      showGoToSettingsDialog(context, error);
    }
  }
}
