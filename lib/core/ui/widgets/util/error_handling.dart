import 'package:flutter/cupertino.dart';
import 'package:jvx_flutterclient/core/utils/app/text_utils.dart';

import '../../../models/api/request.dart';
import '../../../models/api/response.dart';
import '../../../utils/translation/app_localizations.dart';
import '../dialogs/dialogs.dart';

Future<bool> handleError(Response response, BuildContext context) async {
  if (response.hasError) {
    TextUtils.unfocusCurrentTextfield(context);

    if (response.error.name == 'message.sessionexpired') {
      await showSessionExpired(
          context, response.error.title, 'App will restart.');
    } else if (response.error.name == 'message.error' &&
        response.request.requestType == RequestType.STARTUP) {
      await showGoToSettings(context,
          AppLocalizations.of(context).text('Error'), response.error.message);
    } else if (response.error.name == 'message.error') {
      await showError(context, AppLocalizations.of(context).text('Error'),
          response.error.message);
    } else if (response.error.name == 'server.error') {
      await showGoToSettings(context,
          AppLocalizations.of(context).text('Error'), response.error.message);
    } else if (response.error.name == 'connection.error') {
      await showGoToSettings(context,
          AppLocalizations.of(context).text('Error'), response.error.message);
    } else if (response.error.name == 'timeout.error') {
      await showGoToSettings(context,
          AppLocalizations.of(context).text('Error'), response.error.message);
    } else if (response.error.name == 'internet.error') {
      await showError(context, AppLocalizations.of(context).text('Error'),
          response.error.message);
    } else if (response.error.name == 'offline.error') {
      await showError(context, AppLocalizations.of(context).text('Error'),
          response.error.message);
    } else {
      await showGoToSettings(context,
          AppLocalizations.of(context).text('Error'), response.error.message);
    }
    return true;
  }
  return false;
}
