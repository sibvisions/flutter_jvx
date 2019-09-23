import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';

class JVxTextCellEditor extends JVxCellEditor {
  TextEditingController _controller = TextEditingController();
  bool multiLine = false;
  
  JVxTextCellEditor(ComponentProperties properties, BuildContext context) : super(properties, context) {
    multiLine = (properties.getProperty<String>('contentType')?.contains('multiline') ?? false);
  }

  @override
  void setData(JVxData data) {
    if (data!=null && data.columnNames!=null && data.columnNames.length>0 && data.records!=null && 
    data.records.length>0) {
      int index = data.columnNames.indexOf(this.columnName);
      if (index>=0 && index<=data.records[0].length) 
        this.value = data.records[0][index];
    }
    //this.value = getItems(data);
  }
  
  @override
  Widget getWidget() {
    _controller.text = (this.value!=null ? this.value.toString() : "");
    // ToDo: Implement getWidget
    return TextField(
      controller: _controller,
      maxLines: multiLine ? 4 : 1,
      keyboardType: multiLine ? TextInputType.multiline : TextInputType.text,
    );
  }
}