import '../layout/alignments.dart';

import '../api/api_object_property.dart';

class ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The class name of the editor.
  String className = "";

  /// Description of the content
  String? contentType;

  /// The horizontal alignment of the editor.
  HorizontalAlignment horizontalAlignment = HorizontalAlignment.LEFT;

  /// The vertical alignment of the editor.
  VerticalAlignment verticalAlignment = VerticalAlignment.TOP;

  /// If this editor should be shown inside a table.
  bool directCellEditor = false;

  /// The preferred editor mode
  int preferredEditorMode = -1;

  /// If this editor should open in a popup
  bool autoOpenPopup = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [ICellEditorModel] with default values
  ICellEditorModel();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void applyFromJson(Map<String, dynamic> pJson) {
    // ClassName
    var jsonClassName = pJson[ApiObjectProperty.className];
    if (jsonClassName != null) {
      className = jsonClassName;
    }
    // ContentType
    var jsonContentType = pJson[ApiObjectProperty.contentType];
    if (jsonContentType != null) {
      contentType = jsonContentType;
    }
    // HorizontalAlignment
    var jsonHorizontalAlignment = pJson[ApiObjectProperty.horizontalAlignment];
    if (jsonHorizontalAlignment != null) {
      horizontalAlignment = HorizontalAlignment.values[jsonHorizontalAlignment];
    }
    // VerticalAlignment
    var jsonVerticalAlignment = pJson[ApiObjectProperty.verticalAlignment];
    if (jsonVerticalAlignment != null) {
      verticalAlignment = VerticalAlignment.values[jsonVerticalAlignment];
    }
    // DirectCellEditor
    var jsonDirectCellEditor = pJson[ApiObjectProperty.directCellEditor];
    if (jsonDirectCellEditor != null) {
      directCellEditor = jsonDirectCellEditor;
    }
    // PreferredEditorMode
    var jsonPreferredEditorMode = pJson[ApiObjectProperty.preferredEditorMode];
    if (jsonPreferredEditorMode != null) {
      preferredEditorMode = jsonPreferredEditorMode;
    }
    // AutoOpenPopup
    var jsonAutoOpenPopup = pJson[ApiObjectProperty.autoOpenPopup];
    if (jsonAutoOpenPopup != null) {
      autoOpenPopup = jsonAutoOpenPopup;
    }
  }
}
