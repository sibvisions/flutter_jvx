class UrlConfig {

  final String host;
  final String path;
  final bool https;
  final int port;

  UrlConfig({
    required this.host,
    required this.path,
    required this.https,
    required this.port
  });

  String getBasePath() {
    String url = "";
    if(https) {
      url += "https://";
    } else {
      url += "http://";
    }
    url += host;
    url += ":" + port.toString();
    url += path;
    return url;
  }
}