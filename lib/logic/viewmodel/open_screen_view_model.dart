import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/di/dependency_injection.dart';
import 'package:jvx_mobile_v3/model/action.dart' as prefix0;
import 'package:jvx_mobile_v3/model/open_screen/open_screen.dart';
import 'package:jvx_mobile_v3/model/open_screen/open_screen_resp.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/real/real_open_screen_service.dart';

class OpenScreenViewModel {
  String clientId;
  bool manualClose;
  prefix0.Action action;
  NetworkServiceResponse apiResult;
  OpenScreenService openScreenRepo = Injector().openScreenService;

  OpenScreenViewModel({@required this.clientId, @required this.manualClose, @required this.action});

  Future<Null> performOpenScreen(OpenScreenViewModel openScreenViewModel) async {
    NetworkServiceResponse<OpenScreenResponse> result = await openScreenRepo.fetchOpenScreenResponse(OpenScreen(clientId: openScreenViewModel.clientId, manualClose: openScreenViewModel.manualClose, action: openScreenViewModel.action));
    this.apiResult = result;  
  }
}