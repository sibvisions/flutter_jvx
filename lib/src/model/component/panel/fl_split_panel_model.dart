import '../../../service/api/shared/api_object_property.dart';
import 'fl_panel_model.dart';

enum SplitOrientation { HORIZONTAL, VERTICAL }

class FlSplitPanelModel extends FlPanelModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The initial position of the divider in the split.
  double dividerPosition = 50;

  /// The way the panels are split up.
  SplitOrientation orientation = SplitOrientation.VERTICAL;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlSplitPanelModel]
  FlSplitPanelModel() : super() {
    layout = "SplitLayout";
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlSplitPanelModel get defaultModel => FlSplitPanelModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    // currently ignored as its sent in pixels, which are not mobile friendly

    // Orientation
    orientation = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.orientation,
      pDefault: defaultModel.orientation,
      pCurrent: orientation,
      pConversion: orientationFromDynamic,
    );
  }

  static SplitOrientation orientationFromDynamic(dynamic pValue) {
    if (pValue != 1) {
      return SplitOrientation.HORIZONTAL;
    } else {
      return SplitOrientation.VERTICAL;
    }
  }
}
