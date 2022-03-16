class UrlConfig {

  final String host;
  final String path;
  final bool https;
  final int? port;

  UrlConfig({
    required this.host,
    required this.path,
    required this.https,
    this.port
  });

  String getBasePath() {
    String url = "";
    if(https) {
      url += "https://";
    } else {
      url += "http://";
    }
    url += host;
    if(port != null) {
      url += ":" + port.toString();
    }
    url += path;
    return url;
  }
}