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
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);
    // DividerPosition
    var jsonDividerPosition = pJson[ApiObjectProperty.dividerPosition];
    if (jsonDividerPosition != null) {
      if (jsonDividerPosition == -1) {
        dividerPosition = 50;
      } else {
        // TODO
        //dividerPosition = jsonDividerPosition.toDouble();
      }
    }
    // Orientation
    var jsonOrientation = pJson[ApiObjectProperty.orientation];
    if (jsonOrientation != null) {
      if (jsonOrientation != 1) {
        orientation = SPLIT_ORIENTATION.HORIZONTAL;
      } else {
        orientation = SPLIT_ORIENTATION.VERTICAL;
      }
    }
  }
}
