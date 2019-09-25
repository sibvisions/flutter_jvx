import 'package:jvx_mobile_v3/model/startup/startup.dart' as prefix0;
import 'package:jvx_mobile_v3/model/startup/startup_resp.dart';
import 'package:jvx_mobile_v3/services/abstract/i_startup_service.dart';
import 'package:jvx_mobile_v3/services/network_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class StartupService extends NetworkService implements IStartupService {
  static const _kStartupUrl = '/api/startup';

  StartupService(RestClient rest) : super(rest);

  @override
  Future<NetworkServiceResponse<StartupResponse>> fetchStartupResponse(prefix0.Startup startup) async {
    var result = await rest.postAsync(_kStartupUrl, startup);

    if (result.mappedResult != null) {
      var res = StartupResponse.fromJson(result.mappedResult);
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