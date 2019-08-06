import 'package:jvx_mobile_v3/model/logout/logout.dart';
import 'package:jvx_mobile_v3/services/abstract/i_logout_service.dart';
import 'package:jvx_mobile_v3/services/network_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';
import 'package:jvx_mobile_v3/utils/shared_preferences_helper.dart';

class LogoutService extends NetworkService implements ILogoutService {
  static const _kLoginUrl = '/api/logout';

  LogoutService(RestClient rest) : super(rest);

  @override
  Future<NetworkServiceResponse<List>> fetchLogoutResponse(Logout logout) async {
    var result = await rest.postAsync<List>(_kLoginUrl, logout);

    SharedPreferencesHelper().setLoginData(null, null);
    SharedPreferencesHelper().setAuthKey(null);

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