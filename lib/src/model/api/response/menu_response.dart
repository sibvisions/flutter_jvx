import '../api_object_property.dart';
import 'api_response.dart';

class MenuResponse extends ApiResponse {
  final String componentId;
  final List<MenuEntryResponse> responseMenuItems;


  MenuResponse.fromJson(Map<String, dynamic> json) :
        componentId = json[ApiObjectProperty.componentId],
        responseMenuItems = (json[ApiObjectProperty.entries] as List<dynamic>).map((e) => MenuEntryResponse.fromJson(e)).toList(),
        super.fromJson(json);
}

class MenuEntryResponse {
  final String group;
  final String componentId;
  final String text;
  final String? image;

  MenuEntryResponse({
    required this.componentId,
    required this.text,
    required this.group,
    this.image,
  });

  MenuEntryResponse.fromJson(Map<String, dynamic> json) :
        componentId = json[ApiObjectProperty.componentId],
        text = json[ApiObjectProperty.text],
        image = json[ApiObjectProperty.image],
        group = json[ApiObjectProperty.group];
}