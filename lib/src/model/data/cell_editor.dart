import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';

class ICellEditor extends FlComponentModel {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Description of the content
  String? contentType;

  /// If this editor should be shown inside a table.
  bool directCellEditor = false;

  /// The preferred editor mode
  int preferredEditorMode = -1;

  /// If this editor should open in a popup
  bool autoOpenPopup = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [ICellEditor] with default values
  ICellEditor();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void applyFromJson(Map<String, dynamic> pJson){
    // ContentType
    var jsonContentType = pJson[ApiObjectProperty.contentType];
    if(jsonContentType != null){
      contentType = jsonContentType;
    }
    // DirectCellEditor
    var jsonDirectCellEditor = pJson[ApiObjectProperty.directCellEditor];
    if(jsonDirectCellEditor != null){
      directCellEditor = jsonDirectCellEditor;
    }
    // PreferredEditorMode
    var jsonPreferredEditorMode = pJson[ApiObjectProperty.preferredEditorMode];
    if(jsonPreferredEditorMode != null){
      preferredEditorMode = jsonPreferredEditorMode;
    }
    // AutoOpenPopup
    var jsonAutoOpenPopup = pJson[ApiObjectProperty.autoOpenPopup];
    if(jsonAutoOpenPopup != null){
      autoOpenPopup = jsonAutoOpenPopup;
    }
  }





}