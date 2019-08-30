import 'package:jvx_mobile_v3/model/logout/logout.dart';
import 'package:jvx_mobile_v3/services/abstract/i_logout_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';

class MockLogoutService implements ILogoutService {
  @override
  Future<NetworkServiceResponse<List>> fetchLogoutResponse(Logout logout) async {
    await Future.delayed(Duration(seconds: 2));
    return Future.value(NetworkServiceResponse(success: true, content: kLogoutResponse, message: 'error'));
  }
}

var kLogoutResponse = [];