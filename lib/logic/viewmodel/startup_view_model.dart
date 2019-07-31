import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/di/dependency_injection.dart';
import 'package:jvx_mobile_v3/model/startup/startup.dart';
import 'package:jvx_mobile_v3/model/startup/startup_resp.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/real/real_startup_service.dart';
import 'package:jvx_mobile_v3/utils/shared_preferences_helper.dart';

class StartupViewModel {
  String applicationName;
  bool startupResult = false;
  NetworkServiceResponse apiResult;
  StartupService startupRepo = Injector().startupService;

  StartupViewModel({@required this.applicationName});

  Future<Null> performStartup(StartupViewModel startupViewModel) async {
    await SharedPreferencesHelper().getLoginData().then((onValue) async {
      if (onValue['authKey'] != null) {
        NetworkServiceResponse<StartupResponse> result = await startupRepo.fetchStartupResponse(Startup(applicationName: startupViewModel.applicationName, authKey: onValue['authKey']));
        this.apiResult = result;
      } else {
        NetworkServiceResponse<StartupResponse> result = await startupRepo.fetchStartupResponse(Startup(applicationName: startupViewModel.applicationName));
        this.apiResult = result;
      }
    });
  }
}