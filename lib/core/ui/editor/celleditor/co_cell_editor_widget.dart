import 'package:flutter/material.dart';

import '../../../../injection_container.dart';
import '../../../models/api/editor/cell_editor.dart';
import '../../../models/api/editor/cell_editor_properties.dart';
import '../../../models/api/editor/popup_size.dart';
import '../../../models/app/app_state.dart';
import '../../../utils/theme/hex_color.dart';
import '../co_editor_widget.dart';
import '../editor_component_model.dart';
import 'cell_editor_model.dart';

class CoCellEditorWidget extends StatefulWidget {
  final CellEditor changedCellEditor;
  final CellEditorModel cellEditorModel;
  final bool isTableView;

  const CoCellEditorWidget({
    Key key,
    this.changedCellEditor,
    this.cellEditorModel,
    this.isTableView = false,
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

  AppState appState;

  bool get isPreferredSizeSet => preferredSize != null;
  bool get isMinimumSizeSet => minimumSize != null;
  bool get isMaximumSizeSet => maximumSize != null;

  Size tableMinimumSize;
  bool get isTableMinimumSizeSet => tableMinimumSize != null;

  set value(dynamic value) {
    setState(() {
      (widget as CoCellEditorWidget).cellEditorModel.value = value;
    });
  }

  dynamic get value => (widget as CoCellEditorWidget).cellEditorModel.value;

  VoidCallback onBeginEditing;
  VoidCallback onEndEditing;
  Function(dynamic value, [int index]) onValueChanged;
  ValueChanged<dynamic> onFilter;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    this.appState = sl<AppState>();

    var newVal = CoEditorWidget.of(context)
        .data
        ?.getColumnData(context, CoEditorWidget.of(context).columnName);

    if (!(newVal is int)) {
      this.value = newVal;
    }

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
    indexInTable = ((editorState.widget as CoEditorWidget).componentModel
            as EditorComponentModel)
        .indexInTable;
    var newVal = ((editorState.widget as CoEditorWidget).componentModel
            as EditorComponentModel)
        .value;
    if (newVal != null) {
      value = newVal;
    }
  }

  @override
  Widget build(BuildContext context) {
    setEditorProperties(context);
    return Container();
  }
}
