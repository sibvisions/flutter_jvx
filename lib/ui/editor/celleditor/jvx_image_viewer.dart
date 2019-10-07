import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';

class JVxImageViewer extends JVxCellEditor {
  
  JVxImageViewer(CellEditor changedCellEditor, BuildContext context) : super(changedCellEditor, context);
  
  @override
  Widget getWidget() {
    // ToDo: Implement getWidget
    return Image();
  }
}