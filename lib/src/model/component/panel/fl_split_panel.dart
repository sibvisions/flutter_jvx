import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';
import 'package:flutter_client/src/model/component/panel/fl_panel_model.dart';

enum SPLIT_ORIENTATION {HORIZONTAL, VERTICAL}

class FlSplitPanelModel extends FlPanelModel {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The initial position of the divider in the split.
  double dividerPosition = -1;

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
    if(jsonDividerPosition != null){
      dividerPosition = (jsonDividerPosition as int).toDouble();
    }
    // Orientation
    var jsonOrientation = pJson[ApiObjectProperty.orientation];
    if(jsonOrientation != null){
      if(jsonOrientation != 1){
        orientation = SPLIT_ORIENTATION.HORIZONTAL;
      } else {
        orientation = SPLIT_ORIENTATION.VERTICAL;
      }
    }
  }
}