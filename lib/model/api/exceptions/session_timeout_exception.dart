class SessionExpiredException {
  String title;
  String name;
  String details;
  String message;

  SessionExpiredException({this.title, this.details, this.name, this.message = 'Session timeout. The App will restart'}) {
    title = title;
    details = details;
    name = name;
    message = message;
  }
}