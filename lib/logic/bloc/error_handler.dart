import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_dialogs.dart';

handleError(Response response, BuildContext context) {
  if (response.error) {
    if (response.errorName == 'message.sessionexpired') {
      showSessionExpired(context, response.title, response.message);
    } else if (response.errorName == 'server.error') {
      showSessionExpired(context, response.title, response.message);
    } else if (response.errorName == 'connection.error') {
      showGoToSettings(context, response.title, response.message);
    } else {
      showError(context, response.title, response.message);
    }
  }
}