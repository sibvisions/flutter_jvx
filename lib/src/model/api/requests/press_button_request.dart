import '../api_object_property.dart';

class PressButtonRequest {
  final String componentId;
  final String clientId;

  PressButtonRequest({
    required this.componentId,
    required this.clientId,
  });

  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.componentId: componentId,
      };
}
