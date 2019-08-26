import 'package:flutter/foundation.dart';
import 'package:jvx_mobile_v3/di/dependency_injection.dart';
import 'package:jvx_mobile_v3/model/close_screen/close_screen.dart';
import 'package:jvx_mobile_v3/services/abstract/i_close_screen_request.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';

class CloseScreenViewModel {
  String clientId;
  Key componentId;
  NetworkServiceResponse apiResult;
  ICloseScreenService closeScreenRepo = new Injector().closeScreenService;

  CloseScreenViewModel({@required this.clientId, @required this.componentId});

  Future<Null> performCloseScreen(CloseScreenViewModel closeScreenViewModel) async {
    NetworkServiceResponse<List> result =
      await closeScreenRepo.fetchCloseScreen(
        CloseScreen(componentId: closeScreenViewModel.componentId.toString().replaceAll("[<'", '').replaceAll("'>]", ''), clientId: closeScreenViewModel.clientId)
      );
    this.apiResult = result;
  }
}