import 'package:flutter/material.dart';

import 'celleditor/jvx_cell_editor.dart';

abstract class IEditor {
  Size maximumSize;
  String dataProvider;
  String dataRow;
  String columnName;
  bool readonly = false;
  bool eventFocusGained = false;
  JVxCellEditor cellEditor;

  Widget getWidget();
}