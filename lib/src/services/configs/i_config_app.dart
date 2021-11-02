abstract class IConfigApp {

  String get theme;
  String get appName;
  String? get clientId;
  bool get authenticated;

  set clientId(String? clientId);
  set authenticated(bool isAuthenticated);
}