import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/ui/editor/jvx_cell_editor.dart';

abstract class IEditor {
  JVxCellEditor jVxCellEditor;

  Widget getWidget();
}