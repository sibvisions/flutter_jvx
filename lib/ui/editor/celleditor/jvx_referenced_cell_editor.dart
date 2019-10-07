import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/link_reference.dart';
import 'jvx_cell_editor.dart';

class JVxReferencedCellEditor extends JVxCellEditor {
  LinkReference linkReference;

  JVxReferencedCellEditor(CellEditor changedCellEditor, BuildContext context) : super(changedCellEditor, context) {
      linkReference = changedCellEditor.linkReference;
  }
}