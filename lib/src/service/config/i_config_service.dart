abstract class IConfigService {

  String? getAppName();
  String? getClientId();

  void setClientId(String? clientId);
  void setAppName(String appName);
}