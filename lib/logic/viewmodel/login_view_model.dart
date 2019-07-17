import 'package:flutter/foundation.dart';
import 'package:jvx_mobile_v3/di/dependency_injection.dart';
import 'package:jvx_mobile_v3/model/login/login.dart';
import 'package:jvx_mobile_v3/model/login/login_resp.dart';
import 'package:jvx_mobile_v3/services/abstract/i_login_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class LoginViewModel {
  String username;
  String password;
  bool loginResult = false;
  NetworkServiceResponse apiResult;
  ILoginService loginRepo = new Injector().loginService;

  LoginViewModel({@required this.username});

  LoginViewModel.withPW({@required this.username, @required this.password});

  Future<Null> performLogin(LoginViewModel loginViewModel) async {
    NetworkServiceResponse<LoginResponse> result = await loginRepo.fetchLoginResponse(Login(username: loginViewModel.username, password: loginViewModel.password, clientId: globals.clientId, action: 'Anmelden'));
    this.apiResult = result;
  }
}