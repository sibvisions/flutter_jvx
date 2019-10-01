/// Base Response model for all the responses.
/// 
/// Manages errors for the response classes.
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

  /// Special for [LoginResponse].
  BaseResponse.fromLoginJson(List json) {
    if (json.length > 2) {
      details = json[2]['details'];
      title = json[2]['title'];
      message = json[2]['message'];
      name = json[2]['name'];

      print('MESSAGE: $message');
    }
  }
}