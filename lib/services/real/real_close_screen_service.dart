import 'package:jvx_mobile_v3/model/close_screen/close_screen.dart';
import 'package:jvx_mobile_v3/services/abstract/i_close_screen_service.dart';
import 'package:jvx_mobile_v3/services/network_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';

class CloseScreenService extends NetworkService implements ICloseScreenService {
  static const _kCloseScreenUrl = '/api/closeScreen';

  CloseScreenService(RestClient rest) : super(rest);

  @override
  Future<NetworkServiceResponse<List>> fetchCloseScreen(CloseScreen closeScreen) async {
    var result = await rest.postAsync<List>(_kCloseScreenUrl, closeScreen);
    print(result.mappedResult);
    if (result.mappedResult != null) {
      var res = result.mappedResult;
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