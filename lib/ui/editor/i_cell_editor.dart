import 'package:jvx_mobile_v3/ui/editor/jvx_editor.dart';

abstract class ICellEditor {
  JVxEditor _jVxEditor;

  JVxEditor get jvxEditor;
  set jvxEditor(JVxEditor jVxEditor);

  getValue();
  setValue(value);
}