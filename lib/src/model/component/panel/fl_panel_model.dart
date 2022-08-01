import '../../../components/panel/fl_panel_widget.dart';
import '../../../service/api/shared/api_object_property.dart';
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

  /// The screen title.
  String? screenTitle;

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
  FlPanelModel get defaultModel => FlPanelModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    layout = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.layout,
      pDefault: defaultModel.layout,
      pCurrent: layout,
    );

    layoutData = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.layoutData,
      pDefault: defaultModel.layoutData,
      pCurrent: layoutData,
    );

    screenTitle = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.screenTitle,
      pDefault: defaultModel.screenTitle,
      pCurrent: screenTitle,
    );

    screenClassName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.screenClassName,
      pDefault: defaultModel.screenClassName,
      pCurrent: screenClassName,
    );
  }
}
