import 'dart:async';

import 'package:jvx_mobile_v3/logic/viewmodel/login_view_model.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc {
  final loginController = StreamController<LoginViewModel>();
  final apiController = BehaviorSubject<FetchProcess>();
  final loginResendController = StreamController<bool>();
  final loginResultController = BehaviorSubject<bool>();
  Sink<LoginViewModel> get loginSink => loginController.sink;
  Sink<bool> get resendLoginSink => loginResendController.sink;
  Stream<bool> get loginResult => loginResultController.stream;
  Stream<FetchProcess> get apiResult => apiController.stream;

  LoginBloc() {
    loginController.stream.listen(apiCall);
    loginResendController.stream.listen(resendLogin);
  }

  void apiCall(LoginViewModel loginViewModel) async {
    FetchProcess process = new FetchProcess(loading: true);
    apiController.add(process);
    process.type = ApiType.performLogin;
    await loginViewModel.performLogin(loginViewModel);

    process.loading = false;
    process.response = loginViewModel.apiResult;
    apiController.add(process);
    loginViewModel = null;
  }

  void resendLogin(bool flag) {
    loginResultController.add(false);
  }

  void dispose() {
    loginController.close();
    loginResendController.close();
    apiController.close();
    loginResultController.close();
  }
}