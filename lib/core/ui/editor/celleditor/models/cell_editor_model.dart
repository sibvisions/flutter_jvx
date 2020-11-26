import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/models/app/app_state.dart';
import 'package:jvx_flutterclient/injection_container.dart';

import '../../../../models/api/editor/cell_editor.dart';
import '../../../../models/api/editor/cell_editor_properties.dart';
import '../../../../models/api/editor/popup_size.dart';
import '../../../../utils/theme/hex_color.dart';
import '../../../screen/so_component_data.dart';

class CellEditorModel extends ValueNotifier {
  final CellEditor cellEditor;

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
  dynamic _value;
  String columnName;
  HexColor background;
  HexColor foreground;
  String placeholder;
  String font;
  bool editable = true;
  bool borderVisible;
  bool placeholderVisible;
  int indexInTable;
  TextStyle fontStyle = new TextStyle(fontSize: 16.0, color: Colors.black);

  Size preferredSize;
  Size minimumSize;
  Size maximumSize;

  VoidCallback onBeginEditing;
  VoidCallback onEndEditing;
  Function(BuildContext context, dynamic value, [int index]) onValueChanged;
  ValueChanged<dynamic> onFilter;

  AppState appState;

  bool get isPreferredSizeSet => preferredSize != null;
  bool get isMinimumSizeSet => minimumSize != null;
  bool get isMaximumSizeSet => maximumSize != null;

  Size tableMinimumSize;
  bool get isTableMinimumSizeSet => tableMinimumSize != null;

  set cellEditorValue(dynamic value) {
    this._value = value;
    notifyListeners();
  }

  dynamic get cellEditorValue => this._value;

  CellEditorModel(this.cellEditor) : super(cellEditor) {
    this.appState = sl<AppState>();

    if (this.cellEditor != null) {
      horizontalAlignment = this
          .cellEditor
          .getProperty<int>(CellEditorProperty.HORIZONTAL_ALIGNMENT);
      verticalAlignment = this
          .cellEditor
          .getProperty<int>(CellEditorProperty.VERTICAL_ALIGNMENT);
      preferredEditorMode = this
          .cellEditor
          .getProperty<int>(CellEditorProperty.PREFERRED_EDITOR_MODE);
      contentType =
          this.cellEditor.getProperty<String>(CellEditorProperty.CONTENT_TYPE);
      directCellEditor = this.cellEditor.getProperty<bool>(
          CellEditorProperty.DIRECT_CELL_EDITOR, directCellEditor);
      columnName = this
          .cellEditor
          .getProperty<String>(CellEditorProperty.COLUMN_NAME, columnName);
      dataProvider =
          this.cellEditor.getProperty<String>(CellEditorProperty.DATA_PROVIDER);
      borderVisible = this
          .cellEditor
          .getProperty<bool>(CellEditorProperty.BORDER_VISIBLE, true);
      placeholderVisible = this
          .cellEditor
          .getProperty<bool>(CellEditorProperty.PLACEHOLDER_VISIBLE, true);
    }
  }
}
