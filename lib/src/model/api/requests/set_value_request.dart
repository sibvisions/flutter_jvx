import 'package:flutter_client/src/model/api/api_object_property.dart';

class SetValueRequest{

  final String clientId;
  final String componentId;
  final dynamic value;


  SetValueRequest({
    required this.componentId,
    required this.value,
    required this.clientId
  });

  Map<String, dynamic> toJson() => {
    ApiObjectProperty.clientId: clientId,
    ApiObjectProperty.componentId: componentId,
    ApiObjectProperty.value: value
  };
}