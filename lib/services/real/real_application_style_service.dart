import 'package:jvx_mobile_v3/model/application_style/application_style.dart';
import 'package:jvx_mobile_v3/model/application_style/application_style_resp.dart';
import 'package:jvx_mobile_v3/services/abstract/i_application_style_service.dart';
import 'package:jvx_mobile_v3/services/network_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';

class ApplicationStyleService extends NetworkService implements IApplicationStyleService {
  static const _kApplicationStyleUrl = '/download';

  ApplicationStyleService(RestClient rest) : super(rest);

  @override
  Future<NetworkServiceResponse<ApplicationStyleResponse>> fetchApplicationStyle(ApplicationStyle applicationStyle) async {
    var result = await rest.postAsync<ApplicationStyle>(_kApplicationStyleUrl, applicationStyle);

    try {
      if (result != null) {
        var res = ApplicationStyleResponse.fromJson(result.mappedResult);

        return new NetworkServiceResponse(
          content: res,
          success: result.networkServiceResponse.success
        );
      }
    } catch (e) {
      return new NetworkServiceResponse(
        success: result.networkServiceResponse.success,
        message: result.networkServiceResponse.message
      );
    }

    return new NetworkServiceResponse(
      success: result.networkServiceResponse.success,
      message: result.networkServiceResponse.message
    );
  }
}