import 'package:jvx_mobile_v3/model/open_screen/open_screen.dart';
import 'package:jvx_mobile_v3/model/open_screen/open_screen_resp.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';

abstract class IOpenScreenService {
  Future<NetworkServiceResponse<OpenScreenResponse>> fetchOpenScreenResponse(OpenScreen openScreen);
}