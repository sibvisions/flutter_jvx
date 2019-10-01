/// Model for [Logout] request.
class Logout {
  String clientId;

  Logout({this.clientId});

  Map<String, String> toJson() => {
    'clientId': clientId
  };
}