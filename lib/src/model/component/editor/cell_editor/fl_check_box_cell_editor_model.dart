import 'dart:convert';

import '../../../api/api_object_property.dart';
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
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    // ContentType
    var jsonSelectedValue = pJson[ApiObjectProperty.selectedValue];
    if (jsonSelectedValue != null) {
      selectedValue = jsonSelectedValue;
    }
    var jsonDeselectedValue = pJson[ApiObjectProperty.deselectedValue];
    if (jsonDeselectedValue != null) {
      deselectedValue = jsonDeselectedValue;
    }

    var jsonText = pJson[ApiObjectProperty.text];
    if (jsonText != null) {
      text = utf8.decode((jsonText as String).runes.toList());
    }
  }
}
