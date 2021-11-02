abstract class IConfigApiUrl{
  String get host;
  String get path;

  bool get isHttps;
  int get port;

  String get basePath;
}