class OpenScreenRequest {
  final String clientId;
  final String componentId;
  final bool manualClose;

  OpenScreenRequest({
    required this.clientId,
    required this.componentId,
    this.manualClose = false
  });

  Map<String, dynamic> toJson() => {
    _POpenScreenRequest.clientId : clientId,
    _POpenScreenRequest.componentId : componentId,
    // _POpenScreenRequest.manualClose : manualClose
  };
}

abstract class _POpenScreenRequest{
  static const clientId = "clientId";
  static const componentId = "componentId";
  static const manualClose = "manualClose";
}