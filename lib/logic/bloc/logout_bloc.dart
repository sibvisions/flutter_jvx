import 'dart:async';

import 'package:jvx_mobile_v3/logic/viewmodel/logout_view_model.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:rxdart/subjects.dart';

class LogoutBloc {
  final logoutController = StreamController<LogoutViewModel>();
  final apiController = BehaviorSubject<FetchProcess>();
  final logoutResendController = StreamController<bool>();
  final logoutResultController = BehaviorSubject<bool>();
  Sink<LogoutViewModel> get logoutSink => logoutController.sink;
  Sink<bool> get resendLogoutSink => logoutResendController.sink;
  Stream<bool> get logoutResult => logoutResultController.stream;
  Stream<FetchProcess> get apiResult => apiController.stream;

  LogoutBloc() {
    logoutController.stream.listen(apiCall);
    logoutResendController.stream.listen(resendLogout);
  }

  void apiCall(LogoutViewModel logoutViewModel) async {
    FetchProcess process = new FetchProcess(loading: true);
    apiController.add(process);
    process.type = ApiType.performLogout;
    await logoutViewModel.performLogout(logoutViewModel);

    process.loading = false;
    process.response = logoutViewModel.apiResult;
    apiController.add(process);
    logoutViewModel = null;
  }

  void resendLogout(bool flag) {
    logoutResultController.add(false);
  }

  void dispose() {
    logoutController.close();
    logoutResendController.close();
    apiController.close();
    logoutResultController.close();
  }
}