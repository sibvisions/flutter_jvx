import '../api_object_property.dart';

class OpenScreenRequest {

  final String componentId;
  final String clientId;
  final bool manualClose;

  OpenScreenRequest({
    required this.componentId,
    required this.clientId,
    required this.manualClose
  });

  Map<String, dynamic> toJson() =>
  {
    ApiObjectProperty.clientId: clientId,
    ApiObjectProperty.componentId: componentId,
    ApiObjectProperty.manualClose: manualClose
  };
}