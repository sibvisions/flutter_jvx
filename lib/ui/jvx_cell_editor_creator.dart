import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_text_cell_editor.dart';

class JVxCellEditorCreator {

  static JVxCellEditor create(ComponentProperties properties, BuildContext context) {
    String className = properties.cellEditorProperties.getProperty<String>("className");

    if (className?.isNotEmpty ?? true) {
      if (className=="TextCellEditor") {
        return JVxTextCellEditor(properties.cellEditorProperties, context);
      }
    } 

    return null;
  }
}