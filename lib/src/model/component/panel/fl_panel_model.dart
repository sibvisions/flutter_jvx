import '../../../components/panel/fl_panel_widget.dart';

import '../../api/api_object_property.dart';
import '../fl_component_model.dart';

/// The model for [FlPanelWidget]
class FlPanelModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The name of the layout type.
  String? layout;

  /// The layout data.
  String? layoutData;

  /// The screen class name.
  String? screenClassName;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlPanelModel]
  FlPanelModel() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);
    var jsonLayout = pJson[ApiObjectProperty.layout];
    if (jsonLayout != null) {
      layout = jsonLayout;
    }
    var jsonLayoutData = pJson[ApiObjectProperty.layoutData];
    if (jsonLayoutData != null) {
      layoutData = jsonLayoutData;
    }
    var jsonScreenClassName = pJson[ApiObjectProperty.screenClassName];
    if (jsonScreenClassName != null) {
      screenClassName = jsonScreenClassName;
    }
  }
}
