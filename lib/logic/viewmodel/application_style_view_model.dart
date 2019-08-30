import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/di/dependency_injection.dart';
import 'package:jvx_mobile_v3/model/application_style/application_style.dart';
import 'package:jvx_mobile_v3/model/application_style/application_style_resp.dart';
import 'package:jvx_mobile_v3/services/abstract/i_application_style_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';

class ApplicationStyleViewModel {
  String clientId;
  String name;
  String contentMode;
  NetworkServiceResponse apiResult;
  IApplicationStyleService applicationStyleRepo = new Injector().applicationStyleService;

  ApplicationStyleViewModel({@required this.clientId, this.name, this.contentMode});

  Future<Null> performApplicationStyle(ApplicationStyleViewModel applicationStyleViewModel) async {
    NetworkServiceResponse<ApplicationStyleResponse> result = 
      await applicationStyleRepo.fetchApplicationStyle(
        ApplicationStyle(
          clientId: applicationStyleViewModel.clientId,
          contentMode: applicationStyleViewModel.contentMode,
          name: applicationStyleViewModel.name
        )
      );
    this.apiResult = result;
  }
}