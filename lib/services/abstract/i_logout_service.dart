import 'package:jvx_mobile_v3/model/logout/logout.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';

abstract class ILogoutService {
  Future<NetworkServiceResponse<List>> fetchLogoutResponse(
    Logout logout
  );
}