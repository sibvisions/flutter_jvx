import 'package:jvx_mobile_v3/model/press_button/press_button.dart';
import 'package:jvx_mobile_v3/model/press_button/press_button_resp.dart';
import 'package:jvx_mobile_v3/services/abstract/i_press_button_service.dart';
import 'package:jvx_mobile_v3/services/network_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';

class PressButtonService extends NetworkService implements IPressButtonService {
  static const _kPressButtonUrl = '/api/pressButton';

  PressButtonService(RestClient rest) : super(rest);

  @override
  Future<NetworkServiceResponse<PressButtonResponse>> fetchPressButton(PressButton pressButton) async {
    var result = await rest.postAsync(_kPressButtonUrl, pressButton.toJson());

    if (result.mappedResult != null) {
      var res = PressButtonResponse.fromJson(result.mappedResult);
      return new NetworkServiceResponse(
        content: res,
        success: result.networkServiceResponse.success
      );
    }
    return new NetworkServiceResponse(
      success: result.networkServiceResponse.success,
      message: result.networkServiceResponse.message
    );
  }
}