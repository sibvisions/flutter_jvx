import 'package:flutter/foundation.dart';
import 'package:jvx_mobile_v3/di/dependency_injection.dart';
import 'package:jvx_mobile_v3/model/logout/logout.dart';
import 'package:jvx_mobile_v3/services/abstract/i_logout_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class LogoutViewModel {
  String clientId;
  bool logoutResult = false;
  NetworkServiceResponse apiResult;
  ILogoutService logoutRepo = new Injector().logoutService;

  LogoutViewModel({@required this.clientId});

  Future<Null> performLogout(LogoutViewModel logoutViewModel) async {
    NetworkServiceResponse<List> result = await logoutRepo.fetchLogoutResponse(Logout(clientId: globals.clientId));
    this.apiResult = result;
  }
}