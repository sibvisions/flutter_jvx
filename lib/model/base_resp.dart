

class BaseResponse {
  String details;
  String message;
  String title;
  String name;

  bool get isError {
    return (title=='Error');
  }

  bool get isSessionExpired {
    return (name=="message.sessionexpired");
  }

  BaseResponse();

  BaseResponse.fromJson(List json) {
    if (json.length>0) {
      details = json[0]['details'];
      title = json[0]['title'];
      message = json[0]['message'];
      name = json[0]['name'];
    }
  }

}