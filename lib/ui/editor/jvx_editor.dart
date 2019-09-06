import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'package:jvx_mobile_v3/ui/editor/i_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/jvx_cell_editor.dart';

class JVxEditor extends JVxComponent implements IEditor {

  JVxCellEditor jVxCellEditor;
  
  JVxEditor(Key componentId, BuildContext context) : super(componentId, context);

  @override
  Widget getWidget() {
    return jVxCellEditor.getWidget();
  }
}