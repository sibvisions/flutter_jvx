import 'package:jvx_mobile_v3/model/login/login.dart';
import 'package:jvx_mobile_v3/model/login/login_resp.dart';
import 'package:jvx_mobile_v3/services/abstract/i_login_service.dart';
import 'package:jvx_mobile_v3/services/network_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';
import 'package:jvx_mobile_v3/utils/shared_preferences_helper.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class LoginService extends NetworkService implements ILoginService {
  static const _kLoginUrl = '/api/login';

  LoginService(RestClient rest) : super(rest);

  @override
  Future<NetworkServiceResponse<LoginResponse>> fetchLoginResponse(
      Login login) async {
    var result = await rest.postAsync<LoginResponse>(_kLoginUrl, login);

    globals.username = login.username;

    try {
      if (result.mappedResult != null) {
        var res;
        if (result.mappedResult[1]['name'] == 'authenticationData') {
          res = LoginResponse.fromJson(result.mappedResult);
          SharedPreferencesHelper()
              .setAuthKey(result.mappedResult[1]['authKey']);
          SharedPreferencesHelper().setLoginData(login.username, login.password);
        } else {
          res = LoginResponse.fromJsonWithoutKey(result.mappedResult);
          if (login.createAuthKey) {
            SharedPreferencesHelper()
                .setLoginData(login.username, login.password);
          }
        }
        return new NetworkServiceResponse(
            content: res, success: result.networkServiceResponse.success);
      }
    } catch (e) {
      return new NetworkServiceResponse(
          success: result.networkServiceResponse.success,
          message: result.networkServiceResponse.message);
    }
    return new NetworkServiceResponse(
        success: result.networkServiceResponse.success,
        message: result.networkServiceResponse.message);
  }
}
