

class BaseResponse {
  String details;
  String message;
  String title;

  bool get isError {
    return (title=='Error');
  }

  BaseResponse();

  BaseResponse.fromJson(List json) {
    if (json.length>0) {
      details = json[0]['details'];
      title = json[0]['title'];
      message = json[0]['message'];
    }
  }

}