import 'package:jvx_mobile_v3/model/press_button/press_button.dart';
import 'package:jvx_mobile_v3/model/press_button/press_button_resp.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';

abstract class IPressButtonService {
  Future<NetworkServiceResponse<PressButtonResponse>> fetchPressButton(
    PressButton pressButton
  );
}