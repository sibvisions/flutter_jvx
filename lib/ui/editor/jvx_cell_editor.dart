import 'package:jvx_mobile_v3/ui/editor/i_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/jvx_editor.dart';

class JVxCellEditor implements ICellEditor {
  JVxEditor _jVxEditor;

  JVxCellEditor(this._jVxEditor) : assert(_jVxEditor != null);

  JVxEditor get jvxEditor => _jVxEditor;

  set jvxEditor(JVxEditor jVxEditor) => _jVxEditor = jvxEditor;

  @override
  getValue() {
    return _jVxEditor.getValue();
  }

  @override
  setValue(value) {
    return _jVxEditor.setValue(value);
  }
}