import 'package:flutter/cupertino.dart';
import 'package:jvx_flutterclient/model/cell_editor.dart';
import 'package:jvx_flutterclient/model/popup_size.dart';
import 'package:jvx_flutterclient/model/properties/cell_editor_properties.dart';
import 'package:jvx_flutterclient/model/properties/hex_color.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen/so_component_data.dart';

class CellEditorModel extends ValueNotifier {
  final CellEditor currentCellEditor;

  SoComponentData data;

  bool isTableView = false;
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
  HexColor background;
  HexColor foreground;
  String placeholder;
  String font;
  bool editable = true;
  bool borderVisible;
  bool placeholderVisible;
  int indexInTable;

  Size preferredSize;
  Size minimumSize;
  Size maximumSize;

  bool get isPreferredSizeSet => preferredSize != null;
  bool get isMinimumSizeSet => minimumSize != null;
  bool get isMaximumSizeSet => maximumSize != null;

  Size tableMinimumSize;
  bool get isTableMinimumSizeSet => tableMinimumSize != null;

  VoidCallback onBeginEditing;
  VoidCallback onEndEditing;
  Function(dynamic value, [int index]) onValueChanged;
  ValueChanged<dynamic> onFilter;

  CellEditorModel(this.currentCellEditor) : super(null) {
    horizontalAlignment = this
        .currentCellEditor
        .getProperty<int>(CellEditorProperty.HORIZONTAL_ALIGNMENT);
    verticalAlignment = this
        .currentCellEditor
        .getProperty<int>(CellEditorProperty.VERTICAL_ALIGNMENT);
    preferredEditorMode = this
        .currentCellEditor
        .getProperty<int>(CellEditorProperty.PREFERRED_EDITOR_MODE);
    contentType = this
        .currentCellEditor
        .getProperty<String>(CellEditorProperty.CONTENT_TYPE);
    directCellEditor = this.currentCellEditor.getProperty<bool>(
        CellEditorProperty.DIRECT_CELL_EDITOR, directCellEditor);
    columnName = this
        .currentCellEditor
        .getProperty<String>(CellEditorProperty.COLUMN_NAME, columnName);
    dataProvider = this
        .currentCellEditor
        .getProperty<String>(CellEditorProperty.DATA_PROVIDER);
    borderVisible = this
        .currentCellEditor
        .getProperty<bool>(CellEditorProperty.BORDER_VISIBLE, true);
    placeholderVisible = this
        .currentCellEditor
        .getProperty<bool>(CellEditorProperty.PLACEHOLDER_VISIBLE, true);
  }
}
