import 'package:jvx_mobile_v3/model/close_screen/close_screen.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';

abstract class ICloseScreenService {
  Future<NetworkServiceResponse<List>> fetchCloseScreen(
    CloseScreen closeScreen
  );
}