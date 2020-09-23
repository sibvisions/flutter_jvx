import 'package:flutter/material.dart';

import 'package:jvx_flutterclient/model/cell_editor.dart';
import 'package:jvx_flutterclient/model/popup_size.dart';
import 'package:jvx_flutterclient/model/properties/cell_editor_properties.dart';
import 'package:jvx_flutterclient/model/properties/hex_color.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/celleditor/cell_editor_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/co_editor_widget.dart';

class CoCellEditorWidget extends StatefulWidget {
  final CellEditor changedCellEditor;
  final CellEditorModel cellEditorModel;

  const CoCellEditorWidget({
    Key key,
    this.changedCellEditor,
    this.cellEditorModel,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      CoCellEditorWidgetState<CoCellEditorWidget>();
}

class CoCellEditorWidgetState<T extends StatefulWidget> extends State<T> {
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

  @override
  void initState() {
    super.initState();

    CoEditorWidget.of(context).cellEditor = this;

    if ((widget as CoCellEditorWidget).changedCellEditor != null) {
      horizontalAlignment = (widget as CoCellEditorWidget)
          .changedCellEditor
          .getProperty<int>(CellEditorProperty.HORIZONTAL_ALIGNMENT);
      verticalAlignment = (widget as CoCellEditorWidget)
          .changedCellEditor
          .getProperty<int>(CellEditorProperty.VERTICAL_ALIGNMENT);
      preferredEditorMode = (widget as CoCellEditorWidget)
          .changedCellEditor
          .getProperty<int>(CellEditorProperty.PREFERRED_EDITOR_MODE);
      contentType = (widget as CoCellEditorWidget)
          .changedCellEditor
          .getProperty<String>(CellEditorProperty.CONTENT_TYPE);
      directCellEditor = (widget as CoCellEditorWidget)
          .changedCellEditor
          .getProperty<bool>(
              CellEditorProperty.DIRECT_CELL_EDITOR, directCellEditor);
      columnName = (widget as CoCellEditorWidget)
          .changedCellEditor
          .getProperty<String>(CellEditorProperty.COLUMN_NAME, columnName);
      dataProvider = (widget as CoCellEditorWidget)
          .changedCellEditor
          .getProperty<String>(CellEditorProperty.DATA_PROVIDER);
      borderVisible = (widget as CoCellEditorWidget)
          .changedCellEditor
          .getProperty<bool>(CellEditorProperty.BORDER_VISIBLE, true);
      placeholderVisible = (widget as CoCellEditorWidget)
          .changedCellEditor
          .getProperty<bool>(CellEditorProperty.PLACEHOLDER_VISIBLE, true);
    }
  }

  setEditorProperties(BuildContext context) {
    CoEditorWidgetState editorState = CoEditorWidget.of(context);

    onValueChanged = editorState.onValueChanged;
    onEndEditing = editorState.onEndEditing;
    onBeginEditing = editorState.onBeginEditing;
    onFilter = editorState.onFilter;
    editable = editorState.cellEditorEditable;
    background = editorState.cellEditorBackground;
    foreground = editorState.cellEditorForeground;
    placeholder = editorState.cellEditorPlaceholder;
    horizontalAlignment = editorState.cellEditorHorizontalAlignment;
    font = editorState.cellEditorFont;
  }

  @override
  Widget build(BuildContext context) {
    setEditorProperties(context);
    return Container();
  }
}
