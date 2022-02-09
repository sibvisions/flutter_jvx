import 'package:flutter_client/src/model/component/fl_component_model.dart';
import 'package:flutter_client/src/model/data/cell_editor_model.dart';

import '../../api/api_object_property.dart';

class FlCellEditorComponentModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ICellEditorModel cellEditorModel = ICellEditorModel();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [FlCellEditorComponentModel] with default values
  FlCellEditorComponentModel();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    Map<String, dynamic> cellEditorJson = pJson[ApiObjectProperty.cellEditor];
    cellEditorModel.applyFromJson(cellEditorJson);
  }
}
