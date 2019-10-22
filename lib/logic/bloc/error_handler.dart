import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_dialogs.dart';

bool handleError(Response response, BuildContext context) {
  if (response.error) {
    if (response.errorName == 'message.sessionexpired') {
      showSessionExpired(context, response.title, 'App will restart.');
    } else if (response.errorName == 'message.error' && response.requestType == RequestType.STARTUP) {
      showGoToSettings(context, response.title, response.message);
    } else if (response.errorName == 'message.error') {
      showError(context, response.title, response.message);
    } else if (response.errorName == 'server.error') {
      showSessionExpired(context, response.title, response.message);
    } else if (response.errorName == 'connection.error') {
      showGoToSettings(context, response.title, response.message);
    } else {
      showError(context, response.title, response.message);
    }
    return true;
  }
  return false;
}