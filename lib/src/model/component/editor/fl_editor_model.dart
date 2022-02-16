import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/component/dummy/fl_dummy_cell_editor.dart';
import 'package:flutter_client/util/logging/flutter_logger.dart';

import '../fl_component_model.dart';
import '../i_cell_editor.dart';

class FlEditorModel extends FlComponentModel {
  late String dataRow;

  late String columnName;

  Map<String, dynamic> json;

  ICellEditor cellEditor = FlDummyCellEditor(pCellEditorJson: {});

  FlEditorModel({required this.json});

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    // We have to give the editor wrapper all the necessary informations for the layout.
    super.applyFromJson(pJson);
    applyJsonToJson(pJson, json);

    var jsonColumnName = pJson[ApiObjectProperty.columnName];
    if (jsonColumnName != null) {
      dataRow = jsonColumnName;
    }
    var jsonDataRow = pJson[ApiObjectProperty.dataRow];
    if (jsonDataRow != null) {
      dataRow = jsonDataRow;
    }

    var jsonCellEditor = pJson[ApiObjectProperty.cellEditor];
    if (jsonCellEditor != null) {
      cellEditor.dispose();
      cellEditor =
          ICellEditor.getCellEditor(pCellEditorJson: jsonCellEditor, onChange: onChange, onEndEditing: onEndEditing);
    }
  }

  /// Applies component specific layout size information
  applyComponentInformation(FlComponentModel pComponentModel) {
    preferredSize ??= pComponentModel.preferredSize;
    minimumSize ??= pComponentModel.minimumSize;
    maximumSize ??= pComponentModel.maximumSize;
  }

  applyJsonToJson(Map<String, dynamic> pSource, Map<String, dynamic> pDestination) {
    for (String sourceKey in pSource.keys) {
      dynamic value = pSource[sourceKey];

      if (value is Map<String, dynamic>) {
        if (pDestination[sourceKey] == null) {
          pDestination[sourceKey] = Map.from(value);
        } else {
          applyJsonToJson(value, pDestination[sourceKey]);
        }
      } else {
        pDestination[sourceKey] = value;
      }
    }
  }

  void onChange(dynamic pValue) {}

  void onEndEditing(dynamic pValue) {
    LOGGER.logI(pType: LOG_TYPE.DATA, pMessage: "Value of $id set to $pValue");
    // uiService.sendCommand() // TODO setValueS!!! command
  }

  void dispose() {
    cellEditor.dispose();
  }
}
