import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/ui/tools/restart.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_dialogs.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

bool handleError(Response response, BuildContext context) {
  if (response.error && response.requestType != RequestType.LOGIN) {
    if (response.errorName == 'message.sessionexpired') {
      if (globals.handleSessionTimeout != null && globals.handleSessionTimeout) {
        showSessionExpired(context, response.title, 'App will restart.');
      } else {
        RestartWidget.restartApp(context);
      }
    } else if (response.errorName == 'message.error' && response.requestType == RequestType.STARTUP) {
      showGoToSettings(context, Translations.of(context).text2('Error'), response.message);
    } else if (response.errorName == 'message.error') {
      showError(context, Translations.of(context).text2('Error'), response.message);
    } else if (response.errorName == 'server.error') {
      showGoToSettings(context, Translations.of(context).text2('Error'), response.message);
    } else if (response.errorName == 'connection.error') {
      showGoToSettings(context, Translations.of(context).text2('Error'), response.message);
    } else if (response.errorName == 'timeout.error') {
      showGoToSettings(context, Translations.of(context).text2('Error'), response.message);
    } else {
      showGoToSettings(context, Translations.of(context).text2('Error'), response.message);
    }
    return true;
  }
  return false;
}

Widget errorHandlerListener(Widget child) {
  return BlocListener<ApiBloc, Response>(
    listener: (BuildContext context, Response state) {
      if (state != null && !state.loading && state.error) {
        handleError(state, context);
      }
    },
    child: child,
  );
}

Widget loadingListener(Widget child) {
  return BlocListener<ApiBloc, Response>(
    listener: (BuildContext context, Response state) {
      if (state != null && state.loading && state.requestType == RequestType.LOADING) {
        SchedulerBinding.instance.addPostFrameCallback((_) => showProgress(context));
      }

      if (state != null && !state.loading && state.requestType != RequestType.LOADING) {
        SchedulerBinding.instance.addPostFrameCallback((_) => hideProgress(context));
      }
    },
    child: child,
  );
}

Widget errorAndLoadingListener(Widget child) {
  return BlocListener<ApiBloc, Response>(
    listener: (BuildContext context, Response state) {
      if (state != null && state.loading && state.requestType == RequestType.LOADING) {
        showProgress(context);
      }

      if (state != null && !state.loading && state.requestType != RequestType.LOADING) {
        hideProgress(context);
      }

      if (state != null && !state.loading && state.error) {
        handleError(state, context);
      }
    },
    child: child,
  );
}