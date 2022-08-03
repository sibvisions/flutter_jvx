import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class MenuViewResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Id of the menu
  final String componentId;

  /// List of all [MenuEntryResponse]
  final List<MenuEntryResponse> responseMenuItems;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MenuViewResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : componentId = pJson[ApiObjectProperty.componentId],
        responseMenuItems =
            (pJson[ApiObjectProperty.entries] as List<dynamic>).map((e) => MenuEntryResponse.fromJson(e)).toList(),
        super.fromJson(originalRequest: originalRequest, pJson: pJson);
}

class MenuEntryResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The group this menu entry belongs to
  final String group;

  /// Component id of the attached screen (will be sent in openScreenRequest when pressed)
  final String componentId;

  /// Text to be displayed in the menu entry
  final String text;

  /// Image to be displayed (usually Font-awesome icon)
  final String? image;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MenuEntryResponse({
    required this.componentId,
    required this.text,
    required this.group,
    this.image,
  });

  MenuEntryResponse.fromJson(Map<String, dynamic> json)
      : componentId = json[ApiObjectProperty.componentId],
        text = json[ApiObjectProperty.text],
        image = json[ApiObjectProperty.image],
        group = json[ApiObjectProperty.group];
}
