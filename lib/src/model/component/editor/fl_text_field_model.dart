import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/component/label/fl_label_model.dart';

class FlTextFieldModel extends FlLabelModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The placeholder text inside the textfield if it is empty.
  String placeholder = "";

  // The count of rows of text shown.
  int rows = 1;

  /// The average amount of characters to be seen when unconstrained.
  /// (average character length * columns = wanted width of field in non constrained layouts)
  int columns = 10;

  /// If the textfield has a drawn border.
  bool isBorderVisible = true;

  /// If the textfield is editable or not.
  bool isEditable = true;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTextFieldModel() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    var jsonPlaceholder = pJson[ApiObjectProperty.placeholder];
    if (jsonPlaceholder != null) {
      placeholder = jsonPlaceholder;
    }

    var jsonRows = pJson[ApiObjectProperty.rows];
    if (jsonRows != null) {
      rows = jsonRows;
    }

    var jsonColumns = pJson[ApiObjectProperty.columns];
    if (jsonColumns != null) {
      columns = jsonColumns;
    }

    var jsonBorder = pJson[ApiObjectProperty.border];
    if (jsonBorder != null) {
      isBorderVisible = jsonBorder;
    }

    var jsonEditable = pJson[ApiObjectProperty.editable];
    if (jsonEditable != null) {
      isEditable = jsonEditable;
    }
  }
}
