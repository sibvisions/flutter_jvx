class CloseScreen {
  String componentId;
  String clientId;

  CloseScreen({this.componentId, this.clientId});

  Map<String, String> toJson() => <String, String>{
    'componentId': componentId,
    'clientId': clientId
  };
}