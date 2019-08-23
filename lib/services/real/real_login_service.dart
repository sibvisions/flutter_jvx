import 'package:jvx_mobile_v3/model/login/login.dart';
import 'package:jvx_mobile_v3/model/login/login_resp.dart';
import 'package:jvx_mobile_v3/services/abstract/i_login_service.dart';
import 'package:jvx_mobile_v3/services/network_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';
import 'package:jvx_mobile_v3/utils/shared_preferences_helper.dart';

class LoginService extends NetworkService implements ILoginService {
  static const _kLoginUrl = '/api/login';

  LoginService(RestClient rest) : super(rest);

  @override
  Future<NetworkServiceResponse<LoginResponse>> fetchLoginResponse(Login login) async {
    var result = await rest.postAsync<LoginResponse>(_kLoginUrl, login);

    try {
      if (result.mappedResult != null) {
        var res;
        if (result.mappedResult[1]['name'] == 'authenticationData') {
          SharedPreferencesHelper().setAuthKey(result.mappedResult[1]['authKey']);
          res = LoginResponse.fromJson(result.mappedResult);
        } else {
          if (login.createAuthKey) SharedPreferencesHelper().setLoginData(login.username, login.password);
          res = LoginResponse.fromJsonWithoutKey(result.mappedResult);
        }
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