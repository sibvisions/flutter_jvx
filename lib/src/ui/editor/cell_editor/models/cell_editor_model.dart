import 'package:flutter/material.dart';

import '../../../../../flutterclient.dart';
import '../../../../../injection_container.dart';
import '../../../../models/api/response_objects/response_data/editor/cell_editor.dart';
import '../../../../models/api/response_objects/response_data/editor/cell_editor_properties.dart';
import '../../../../models/api/response_objects/response_data/editor/popup_size.dart';
import '../../../../models/state/app_state.dart';
import '../../../screen/core/so_component_data.dart';

class CellEditorModel extends ChangeNotifier {
  CellEditor cellEditor;

  SoComponentData? data;

  bool isTableView = false;
  int horizontalAlignment = 0;
  int verticalAlignment = 0;
  int? preferredEditorMode;
  String? additionalCondition;
  bool? displayReferenceColumnName;
  bool? displayConcatMask;
  PopupSize? popupSize;
  bool? searchColumnMapping;
  bool? searchTextAnywhere;
  bool? sortByColumnName;
  bool? tableHeaderVisible;
  bool? validationEnabled;
  bool? doNotClearColumnNames;
  bool? tableReadonly;
  bool? directCellEditor = false;
  bool? autoOpenPopup;
  String? contentType;

  String? dataProvider;
  dynamic? _value;
  String? columnName;
  Color? backgroundColor;
  Color? foregroundColor;
  String? placeholder;
  String? font;
  bool _editable = true;
  bool borderVisible = true;
  int indexInTable = -1;
  TextStyle fontStyle = TextStyle(fontSize: 16, color: Colors.black);
  Size? tableMinimumSize;
  Size? tablePreferredSize;

  Size? preferredSize;
  Size? minimumSize;
  Size? maximumSize;

  VoidCallback? onBeginEditing;
  VoidCallback? onEndEditing;
  Function(BuildContext context, dynamic value, [int index])? onValueChanged;
  ValueChanged<dynamic>? onFilter;

  late AppState appState;

  bool get editable => _editable;

  set editable(bool editable) => _editable = editable;

  bool get isPreferredSizeSet => preferredSize != null;
  bool get isMinimumSizeSet => minimumSize != null;
  bool get isMaximumSizeSet => maximumSize != null;
  bool get isTableMinimumSizeSet => tableMinimumSize != null;
  bool get isTablePreferredSizeSet => tablePreferredSize != null;

  set cellEditorValue(dynamic value) {
    _value = value;
    notifyListeners();
  }

  dynamic get cellEditorValue => _value;

  CellEditorModel({required this.cellEditor}) : super() {
    appState = sl<AppState>();

    horizontalAlignment = this.cellEditor.getProperty<int>(
        CellEditorProperty.HORIZONTAL_ALIGNMENT, horizontalAlignment)!;
    verticalAlignment = this.cellEditor.getProperty<int>(
        CellEditorProperty.VERTICAL_ALIGNMENT, verticalAlignment)!;
    preferredEditorMode = this.cellEditor.getProperty<int>(
        CellEditorProperty.PREFERRED_EDITOR_MODE, preferredEditorMode);
    contentType = this
        .cellEditor
        .getProperty<String>(CellEditorProperty.CONTENT_TYPE, contentType);
    directCellEditor = this.cellEditor.getProperty<bool>(
        CellEditorProperty.DIRECT_CELL_EDITOR, directCellEditor);
    // columnName = this
    //     .cellEditor
    //     .getProperty<String>(CellEditorProperty.COLUMN_NAME, columnName);
    dataProvider = this
        .cellEditor
        .getProperty<String>(CellEditorProperty.DATA_PROVIDER, dataProvider);
    borderVisible = this
        .cellEditor
        .getProperty<bool>(CellEditorProperty.BORDER_VISIBLE, true)!;
  }
}
