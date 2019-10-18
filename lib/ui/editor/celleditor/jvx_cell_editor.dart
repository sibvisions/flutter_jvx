import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/column_view.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/link_reference.dart';
import 'package:jvx_mobile_v3/model/popup_size.dart';
import 'package:jvx_mobile_v3/model/properties/cell_editor_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/i_cell_editor.dart';


class JVxCellEditor implements ICellEditor {
  Key key = GlobalKey<FormState>();
  BuildContext context;
  int horizontalAlignment;
  int verticalAlignment;
  int preferredEditorMode;
  String additionalCondition;
  bool displayReferencedColumnName;
  bool displayConcatMask;
  PopupSize popupSize;
  bool searchColumnMapping;
  bool searchTextAnywhere;
  bool sortByColumnName;
  bool tableHeaderVisible;
  bool validationEnabled;
  bool doNotClearColumnNames;
  bool tableReadonly;
  bool directCellEditor = false;
  bool autoOpenPopup;
  String contentType;
  String dataProvider;
  dynamic value;
  String columnName;

  JVxCellEditor(CellEditor changedCellEditor, this.context) {
    horizontalAlignment = changedCellEditor.getProperty<int>(CellEditorProperty.HORIZONTAL_ALIGNMENT);
    verticalAlignment = changedCellEditor.getProperty<int>(CellEditorProperty.VERTICAL_ALIGNMENT);
    preferredEditorMode = changedCellEditor.getProperty<int>(CellEditorProperty.PREFERRED_EDITOR_MODE);
    contentType = changedCellEditor.getProperty<String>(CellEditorProperty.CONTENT_TYPE);
    directCellEditor = changedCellEditor.getProperty<bool>(CellEditorProperty.DIRECT_CELL_EDITOR, directCellEditor);
    columnName = changedCellEditor.getProperty<String>(CellEditorProperty.COLUMN_NAME, columnName);
    dataProvider = changedCellEditor.getProperty<String>(CellEditorProperty.DATA_PROVIDER);
  }

  VoidCallback onBeginEditing;
  VoidCallback onEndEditing;
  ValueChanged<dynamic> onValueChanged;


  @override
  Widget getWidget() {
    // ToDo: Implement getWidget
    return null;
  }
}