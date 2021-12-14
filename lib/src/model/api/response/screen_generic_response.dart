import '../api_object_property.dart';
import 'api_response.dart';


class ScreenGenericResponse extends ApiResponse {

  final String componentId;
  final List<dynamic> changedComponents;
  final bool update;
  final bool home;

  ScreenGenericResponse({
    required this.componentId,
    required this.changedComponents,
    required String name,
    required this.home,
    required this.update
  }) : super(name: name);


  ScreenGenericResponse.fromJson(Map<String, dynamic> json) :
    componentId = json[ApiObjectProperty.componentId],
    changedComponents = json[ApiObjectProperty.changedComponents],
    update = json[ApiObjectProperty.update],
    home = json[ApiObjectProperty.home],
    super.fromJson(json);
}