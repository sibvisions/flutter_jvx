import 'package:flutter/foundation.dart';
import 'package:jvx_mobile_v3/di/dependency_injection.dart';
import 'package:jvx_mobile_v3/model/action.dart';
import 'package:jvx_mobile_v3/model/press_button/press_button.dart';
import 'package:jvx_mobile_v3/model/press_button/press_button_resp.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/real/real_press_button_service.dart';

class PressButtonViewModel {
  String clientId;
  Action action;
  NetworkServiceResponse apiResult;
  PressButtonService pressButtonRepo = Injector().pressButtonService;

  PressButtonViewModel({@required this.clientId, this.action});

  Future<Null> performPressButton(PressButtonViewModel pressButtonViewModel) async {
    NetworkServiceResponse<PressButtonResponse> result = 
      await pressButtonRepo.fetchPressButton(PressButton(action: pressButtonViewModel.action, clientId: pressButtonViewModel.clientId));
    this.apiResult = result;
  }
}