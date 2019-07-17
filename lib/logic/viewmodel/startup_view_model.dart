import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/di/dependency_injection.dart';
import 'package:jvx_mobile_v3/model/startup/startup.dart';
import 'package:jvx_mobile_v3/model/startup/startup_resp.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/real/real_startup_service.dart';

class StartupViewModel {
  String applicationName;
  bool startupResult = false;
  NetworkServiceResponse apiResult;
  StartupService startupRepo = Injector().startupService;

  StartupViewModel({@required this.applicationName});

  Future<Null> performStartup(StartupViewModel startupViewModel) async {
    NetworkServiceResponse<StartupResponse> result = await startupRepo.fetchStartupResponse(Startup(applicationName: startupViewModel.applicationName));
    this.apiResult = result;
  }
}