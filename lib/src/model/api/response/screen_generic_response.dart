import '../api_object_property.dart';
import 'api_response.dart';

class ScreenGenericResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the screen
  final String componentId;

  /// List of all changed and new components
  final List<dynamic>? changedComponents;

  /// False if this should be displayed on top
  final bool update;
  final bool home;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ScreenGenericResponse({
    required this.componentId,
    required this.changedComponents,
    required this.home,
    required this.update,
    required String name,
    required Object originalRequest,
  }) : super(name: name, originalRequest: originalRequest);

  ScreenGenericResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : componentId = pJson[ApiObjectProperty.componentId],
        changedComponents = pJson[ApiObjectProperty.changedComponents],
        update = pJson[ApiObjectProperty.update],
        home = pJson[ApiObjectProperty.home],
        super.fromJson(pJson: pJson, originalRequest: originalRequest);
}
