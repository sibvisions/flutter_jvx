import 'package:flutter/material.dart';
import '../screen/so_component_data.dart';

import 'celleditor/co_cell_editor.dart';

abstract class IEditor {
  Size maximumSize;
  String dataProvider;
  String dataRow;
  String columnName;
  bool readonly = false;
  bool eventFocusGained = false;
  bool cellEditorEditable;
  String cellEditorPlaceholder;
  Color cellEditorBackground;
  Color cellEditorForeground;
  int cellEditorHorizontalAlignment;
  String cellEditorFont;
  CoCellEditor cellEditor;
  SoComponentData data;

  Widget getWidget();
}
