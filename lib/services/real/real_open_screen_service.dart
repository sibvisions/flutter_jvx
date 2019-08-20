import 'package:jvx_mobile_v3/model/open_screen/open_screen.dart' as prefix0;
import 'package:jvx_mobile_v3/model/open_screen/open_screen_resp.dart';
import 'package:jvx_mobile_v3/services/abstract/i_open_screen_service.dart';
import 'package:jvx_mobile_v3/services/network_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';

class OpenScreenService extends NetworkService implements IOpenScreenService {
  static const _kOpenScreenUrl = '/api/openScreen';

  OpenScreenService(RestClient rest) : super(rest);

  @override
  Future<NetworkServiceResponse<OpenScreenResponse>> fetchOpenScreenResponse(prefix0.OpenScreen openScreen) async {
    var result = await rest.postAsync(_kOpenScreenUrl, openScreen.toJson());

    if (result.mappedResult != null) {
      var res = OpenScreenResponse.fromJson(result.mappedResult);
      print(res.changedComponents[0].layout);
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