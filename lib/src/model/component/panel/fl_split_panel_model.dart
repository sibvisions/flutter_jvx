import '../../api/api_object_property.dart';
import 'fl_panel_model.dart';

enum SPLIT_ORIENTATION { HORIZONTAL, VERTICAL }

class FlSplitPanelModel extends FlPanelModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The initial position of the divider in the split.
  double dividerPosition = 50;

  /// The way the panels are split up.
  SPLIT_ORIENTATION orientation = SPLIT_ORIENTATION.VERTICAL;

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

    // TODO DividerPosition -> currently ignored as its sent in pixels

    // Orientation
    orientation = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.orientation,
      pDefault: defaultModel.orientation,
      pCurrent: orientation,
      pConversion: orientationFromDynamic,
    );
  }

  static SPLIT_ORIENTATION orientationFromDynamic(dynamic pValue) {
    if (pValue != 1) {
      return SPLIT_ORIENTATION.HORIZONTAL;
    } else {
      return SPLIT_ORIENTATION.VERTICAL;
    }
  }
}
