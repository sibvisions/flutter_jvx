import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class GenericScreenViewResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the screen
  final String screenName;

  /// List of all changed and new components
  final List<dynamic>? changedComponents;

  /// False if this should be displayed on top
  final bool update;
  final bool home;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  GenericScreenViewResponse({
    required this.screenName,
    required this.changedComponents,
    required this.home,
    required this.update,
    required super.name,
    required super.originalRequest,
  });

  GenericScreenViewResponse.fromJson(super.json, super.originalRequest)
      : screenName = json[ApiObjectProperty.componentId],
        changedComponents = json[ApiObjectProperty.changedComponents],
        update = json[ApiObjectProperty.update],
        home = json[ApiObjectProperty.home],
        super.fromJson();
}
