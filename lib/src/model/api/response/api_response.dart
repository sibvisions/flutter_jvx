import '../api_object_property.dart';

class ApiResponse{
  String name;

  ApiResponse({
    required this.name
  });

  ApiResponse.fromJson(Map<String, dynamic> json) :
        name = json[ApiObjectProperty.name];
}