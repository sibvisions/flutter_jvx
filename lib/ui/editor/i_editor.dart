import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/ui/screen/component_data.dart';

import 'celleditor/jvx_cell_editor.dart';

abstract class IEditor {
  Size maximumSize;
  String dataProvider;
  String dataRow;
  String columnName;
  bool readonly = false;
  bool eventFocusGained = false;
  JVxCellEditor cellEditor;
  ComponentData data;

  Widget getWidget();
}