mixin BaseUrlBuilder {

  String getBaseUrl({
    required bool https,
    required String host,
    required int? port,
    required pathToService
  }) {
    String url = "";

    if(https) {
      url += "https://";
    } else {
      url += "http://";
    }
    url += host;
    int? temp = port;
    if(temp != null){
      url += ":" + temp.toString();
    }
    url += pathToService;
    return url;
  }
}