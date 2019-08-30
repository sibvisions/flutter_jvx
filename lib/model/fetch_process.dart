import 'package:jvx_mobile_v3/services/network_service_response.dart';

enum ApiType { performStartup, performLogin, performLogout, performDownload, performOpenScreen, performCloseScreen, performPressButton, performApplicationStyle }

class FetchProcess<T> {
  ApiType type;
  bool loading;
  NetworkServiceResponse<T> response;

  FetchProcess({this.loading, this.response, this.type});
}