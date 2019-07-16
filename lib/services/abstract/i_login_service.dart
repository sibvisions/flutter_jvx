import 'package:jvx_mobile_v3/model/login/login.dart';
import 'package:jvx_mobile_v3/model/login/login_resp.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';

abstract class ILoginService {
  Future<NetworkServiceResponse<LoginResponse>> fetchLoginResponse(
    Login userLogin
  );
}