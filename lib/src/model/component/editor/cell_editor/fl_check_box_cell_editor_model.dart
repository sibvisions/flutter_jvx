import 'dart:convert';

import '../../../../service/api/shared/api_object_property.dart';
import 'cell_editor_model.dart';

class FlCheckBoxCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The value to send if selected.
  dynamic selectedValue;

  /// The value to send if deselected.
  dynamic deselectedValue;

  /// The text to show next to the checkbox.
  String text = "";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  FlCheckBoxCellEditorModel get defaultModel => FlCheckBoxCellEditorModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    // ContentType
    selectedValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.selectedValue,
      pDefault: defaultModel.selectedValue,
      pCurrent: selectedValue,
    );

    deselectedValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.deselectedValue,
      pDefault: defaultModel.deselectedValue,
      pCurrent: deselectedValue,
    );

    text = getPropertyValue(
        pJson: pJson,
        pKey: ApiObjectProperty.text,
        pDefault: defaultModel.text,
        pCurrent: text,
        pConversion: (value) => utf8.decode((value as String).runes.toList()));
  }
}
