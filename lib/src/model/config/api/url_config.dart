class UrlConfig {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Domain part of the url
  /// http://_HOST_/bar/foo
  final String host;
  /// Additional path needs to always end with 'services/mobile/
  /// http://host/BAR/FOO/SERVICES/MOBILE
  final String path;
  /// 'true' if path should be 'https'
  final bool https;
  /// Port
  final int? port;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  UrlConfig({
    required this.host,
    required this.path,
    required this.https,
    this.port
  });
  
  UrlConfig.fromFullString({required String fullPath}) :
    https = extractIfHttps(url: fullPath),
    port = extractPort(url: fullPath),
    host = extractHost(url: fullPath),
    path = extractPath(url: fullPath);

  UrlConfig.fromJson({required Map<String, dynamic> json}) :
    https = json["https"],
    port = json["port"],
    host = json["host"],
    path = json["path"];

  UrlConfig.empty() :
    host = "",
    path = "",
    https = false,
    port = null;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Will return the full url
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
  
  static bool extractIfHttps({required String url}){
    return url.startsWith("https");
  }

  static int? extractPort({required String url}){
    bool containsHttp = url.startsWith("http");

    if(containsHttp){
      String split = url.replaceFirst("http://", "").replaceFirst("https://", "");

      bool containsPort = split.contains(":");
      if(containsPort){
        int indexOffStart = split.indexOf(":");
        int portLength = split.indexOf("/", split.indexOf(":"));
        return int.parse(split.substring(indexOffStart, indexOffStart+portLength));
      }
    }
    return null;
  }

  static String extractHost({required String url}) {

    bool startsWithHttp = url.startsWith("http");

    if(startsWithHttp){
      return url.split("://")[1].split("/")[0].split(":")[0];
    } else {
      return url.split("/")[0].split(":")[0];
    }
  }

  static String extractPath({required String url}) {

    bool startsWithHttp = url.startsWith("http");

    if(startsWithHttp){
      return "/" + url.split("/").sublist(3).reduce((value, element) => "$value/$element");
    } else {
      return "/" + url.split("/").sublist(1).reduce((value, element) => "$value/$element");
    }
  }
  
}