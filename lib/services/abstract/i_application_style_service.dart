import 'package:jvx_mobile_v3/model/application_style/application_style.dart';
import 'package:jvx_mobile_v3/model/application_style/application_style_resp.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';

abstract class IApplicationStyleService {
  Future<NetworkServiceResponse<ApplicationStyleResponse>> fetchApplicationStyle(
    ApplicationStyle applicationStyle
  );
}