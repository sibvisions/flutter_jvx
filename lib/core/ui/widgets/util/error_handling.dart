import 'package:flutter/cupertino.dart';

import '../../../models/api/request.dart';
import '../../../models/api/response.dart';
import '../../../utils/translation/app_localizations.dart';
import '../dialogs/dialogs.dart';

bool handleError(Response response, BuildContext context) {
  if (response.hasError) {
    if (response.error.name == 'message.sessionexpired') {
      showSessionExpired(context, response.error.title, 'App will restart.');
    } else if (response.error.name == 'message.error' &&
        response.request.requestType == RequestType.STARTUP) {
      showGoToSettings(context, AppLocalizations.of(context).text('Error'),
          response.error.message);
    } else if (response.error.name == 'message.error') {
      showError(context, AppLocalizations.of(context).text('Error'),
          response.error.message);
    } else if (response.error.name == 'server.error') {
      showGoToSettings(context, AppLocalizations.of(context).text('Error'),
          response.error.message);
    } else if (response.error.name == 'connection.error') {
      showGoToSettings(context, AppLocalizations.of(context).text('Error'),
          response.error.message);
    } else if (response.error.name == 'timeout.error') {
      showGoToSettings(context, AppLocalizations.of(context).text('Error'),
          response.error.message);
    } else if (response.error.name == 'internet.error') {
      showError(context, AppLocalizations.of(context).text('Error'),
          response.error.message);
    } else {
      showGoToSettings(context, AppLocalizations.of(context).text('Error'),
          response.error.message);
    }
    return true;
  }
  return false;
}
