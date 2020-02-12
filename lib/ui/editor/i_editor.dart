import 'package:flutter/material.dart';
import '../../ui/screen/component_data.dart';

import 'celleditor/jvx_cell_editor.dart';

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
  JVxCellEditor cellEditor;
  ComponentData data;

  Widget getWidget();
}