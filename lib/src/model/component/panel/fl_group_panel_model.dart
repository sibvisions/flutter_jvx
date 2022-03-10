import 'package:flutter_client/src/model/layout/alignments.dart';

import '../../../components/panel/group/fl_group_panel_wrapper.dart';
import '../../api/api_object_property.dart';
import '../label/fl_label_model.dart';
import 'fl_panel_model.dart';

class FlGroupPanelModel extends FlPanelModel implements FlLabelModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The text shown in the [FlGroupPanelWrapper]
  @override
  String text = "";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlGroupPanelModel]
  FlGroupPanelModel() : super() {
    horizontalAlignment = HorizontalAlignment.LEFT;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    var jsonText = pJson[ApiObjectProperty.text];
    if (jsonText != null) {
      text = jsonText;
    }
  }
}
