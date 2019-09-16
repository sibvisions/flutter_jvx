import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_image_viewer.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_number_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_text_cell_editor.dart';

import 'editor/celleditor/jvx_date_cell_editor.dart';
import 'editor/celleditor/jvx_linked_cell_editor.dart';

class JVxCellEditorCreator {

  static JVxCellEditor create(ComponentProperties properties, BuildContext context) {
    JVxCellEditor jVxCellEditor;

    String className = properties.cellEditorProperties.getProperty<String>("className");

    if (className?.isNotEmpty ?? true) {
      if (className=="TextCellEditor") {
        jVxCellEditor = JVxTextCellEditor(properties.cellEditorProperties, context);
      } else if (className=="NumberCellEditor") {
        jVxCellEditor = JVxNumberCellEditor(properties.cellEditorProperties, context);
      } else if (className=="LinkedCellEditor") {
        jVxCellEditor = JVxLinkedCellEditor(properties.cellEditorProperties, context);
      } else if (className=="DateCellEditor") {
        jVxCellEditor = JVxDateCellEditor(properties.cellEditorProperties, context);
      } else if (className=="ImageViewer") {
        jVxCellEditor = JVxImageViewer(properties.cellEditorProperties, context);
      } else {
        jVxCellEditor = JVxTextCellEditor(properties.cellEditorProperties, context);
      }

      jVxCellEditor.dataProvider = properties.getProperty<String>("dataProvider");
    }


    return jVxCellEditor;
  }
}