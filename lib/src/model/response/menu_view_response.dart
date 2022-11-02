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

  MenuViewResponse.fromJson(super.json)
      : componentId = json[ApiObjectProperty.componentId],
        responseMenuItems =
            (json[ApiObjectProperty.entries] as List<dynamic>?)?.map((e) => MenuEntryResponse.fromJson(e)).toList() ??
                [],
        super.fromJson();
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

  /// Alternative Text to be displayed in the menu entry
  final String? sideBarText;

  /// Alternative Text to be displayed in the menu entry
  final String? quickBarText;

  /// Image to be displayed (usually Font-awesome icon)
  final String? image;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MenuEntryResponse({
    required this.componentId,
    required this.text,
    this.sideBarText,
    this.quickBarText,
    required this.group,
    this.image,
  });

  MenuEntryResponse.fromJson(Map<String, dynamic> json)
      : componentId = json[ApiObjectProperty.componentId],
        text = json[ApiObjectProperty.text],
        sideBarText = json[ApiObjectProperty.sideBarText],
        quickBarText = json[ApiObjectProperty.quickBarText],
        image = json[ApiObjectProperty.image],
        group = json[ApiObjectProperty.group];
}
