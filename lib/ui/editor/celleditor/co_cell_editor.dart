import 'package:flutter/widgets.dart';

import '../../../model/cell_editor.dart';
import '../../../model/popup_size.dart';
import '../../../model/properties/cell_editor_properties.dart';
import '../../../model/properties/hex_color.dart';
import 'i_cell_editor.dart';

class CoCellEditor implements ICellEditor {
  Key key = GlobalKey<FormState>();
  BuildContext context;
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

  Size preferredSize;
  Size minimumSize;
  Size maximumSize;

  bool get isPreferredSizeSet => preferredSize != null;
  bool get isMinimumSizeSet => minimumSize != null;
  bool get isMaximumSizeSet => maximumSize != null;

  Size tableMinimumSize;
  bool get isTableMinimumSizeSet => tableMinimumSize != null;

  CoCellEditor(CellEditor changedCellEditor, this.context) {
    horizontalAlignment = changedCellEditor
        .getProperty<int>(CellEditorProperty.HORIZONTAL_ALIGNMENT);
    verticalAlignment = changedCellEditor
        .getProperty<int>(CellEditorProperty.VERTICAL_ALIGNMENT);
    preferredEditorMode = changedCellEditor
        .getProperty<int>(CellEditorProperty.PREFERRED_EDITOR_MODE);
    contentType =
        changedCellEditor.getProperty<String>(CellEditorProperty.CONTENT_TYPE);
    directCellEditor = changedCellEditor.getProperty<bool>(
        CellEditorProperty.DIRECT_CELL_EDITOR, directCellEditor);
    columnName = changedCellEditor.getProperty<String>(
        CellEditorProperty.COLUMN_NAME, columnName);
    dataProvider =
        changedCellEditor.getProperty<String>(CellEditorProperty.DATA_PROVIDER);
    borderVisible = changedCellEditor.getProperty<bool>(
        CellEditorProperty.BORDER_VISIBLE, true);
    placeholderVisible = changedCellEditor.getProperty<bool>(
        CellEditorProperty.PLACEHOLDER_VISIBLE, true);
  }

  VoidCallback onBeginEditing;
  VoidCallback onEndEditing;
  ValueChanged<dynamic> onValueChanged;
  ValueChanged<dynamic> onFilter;

  @override
  Widget getWidget(
      {bool editable,
      Color background,
      Color foreground,
      String placeholder,
      String font,
      int horizontalAlignment}) {
    // ToDo: Implement getWidget
    return null;
  }

  setEditorProperties(
      {bool editable,
      Color background,
      Color foreground,
      String placeholder,
      String font,
      int horizontalAlignment}) {
    if (background != null) {
      this.background = background;
    }
    if (editable != null) {
      this.editable = editable;
    }
    if (foreground != null) {
      this.foreground = foreground;
    }
    if (placeholder != null) {
      this.placeholder = placeholder;
    }
    if (font != null) {
      this.font = font;
    }
    if (horizontalAlignment != null) {
      this.horizontalAlignment = horizontalAlignment;
    }
  }
}
