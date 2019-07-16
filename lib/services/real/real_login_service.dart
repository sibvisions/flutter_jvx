import 'package:jvx_mobile_v3/model/login/login.dart';
import 'package:jvx_mobile_v3/model/login/login_resp.dart';
import 'package:jvx_mobile_v3/services/abstract/i_login_service.dart';
import 'package:jvx_mobile_v3/services/network_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';

class LoginService extends NetworkService implements ILoginService {
  static const _kLoginUrl = '/api/login';

  LoginService(RestClient rest) : super(rest);

  @override
  Future<NetworkServiceResponse<LoginResponse>> fetchLoginResponse(Login login) async {
    var result = await rest.postAsync<LoginResponse>(_kLoginUrl, login);

    if (result.mappedResult != null) {
      var res = LoginResponse.fromJson(result.mappedResult);
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