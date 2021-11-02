class OpenScreenRequest {
  final String clientId;
  final String componentId;

  OpenScreenRequest({
    required this.clientId,
    required this.componentId
  });

  Map<String, dynamic> toJson() => {
    _POpenScreenRequest.clientId : clientId,
    _POpenScreenRequest.componentId : componentId
  };
}

abstract class _POpenScreenRequest{
  static const clientId = "clientId";
  static const componentId = "componentId";
}