import 'package:flutter_client/src/model/api/api_object_property.dart';

class DeviceStatusRequest {

  final String clientId;
  final double screenWidth;
  final double screenHeight;

  DeviceStatusRequest({
    required this.clientId,
    required this.screenWidth,
    required this.screenHeight
  });

  Map<String, dynamic> toJson() => {
    ApiObjectProperty.clientId : clientId,
    ApiObjectProperty.screenHeight : screenHeight,
    ApiObjectProperty.screenWidth : screenWidth
  };

}