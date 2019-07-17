import 'package:jvx_mobile_v3/model/login/login.dart';
import 'package:jvx_mobile_v3/model/login/login_resp.dart';
import 'package:jvx_mobile_v3/model/login_data.dart';
import 'package:jvx_mobile_v3/model/login_password.dart';
import 'package:jvx_mobile_v3/model/login_username.dart';
import 'package:jvx_mobile_v3/services/abstract/i_login_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';


class MockLoginService implements ILoginService {
  @override
  Future<NetworkServiceResponse<LoginResponse>> fetchLoginResponse(Login login) async {
    await Future.delayed(Duration(seconds: 2));
    // return Future.value(NetworkServiceResponse(success: true, content: kLoginResponse, message: UIData.something_went_wrong));
  }
}
/*
var kLoginResponse = new LoginResponse(
  data: new LoginData(username: new LoginUsername(componentId: 'UserName', text: 'admin'), password: new LoginPassword(componentId: 'Password', text: '')), status: 'success'
);
*/