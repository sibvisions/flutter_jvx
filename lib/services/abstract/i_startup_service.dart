import 'package:jvx_mobile_v3/model/startup/startup.dart';
import 'package:jvx_mobile_v3/model/startup/startup_resp.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';

abstract class IStartupService {
  Future<NetworkServiceResponse<StartupResponse>> fetchStartupResponse(Startup startup);
}