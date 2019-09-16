import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'package:jvx_mobile_v3/ui/editor/i_editor.dart';

import '../../main.dart';
import '../jvx_screen.dart';
import 'celleditor/jvx_cell_editor.dart';
import 'celleditor/jvx_linked_cell_editor.dart';

class JVxEditor extends JVxComponent implements IEditor {
  Size maximumSize;
  String dataProvider;
  String dataRow;
  String columnName;
  bool readonly = false;
  bool eventFocusGained = false;
  JVxCellEditor cellEditor;
  
  JVxEditor(Key componentId, BuildContext context) : super(componentId, context);

  @override
  void updateProperties(ComponentProperties properties) {
    super.updateProperties(properties);
    maximumSize = properties.getProperty<Size>("maximumSize",null);
    dataProvider = properties.getProperty<String>("dataProvider");
    dataRow = properties.getProperty<String>("dataRow");
    columnName = properties.getProperty<String>("columnName");
    readonly = properties.getProperty<bool>("readonly", readonly);
    eventFocusGained = properties.getProperty<bool>("eventFocusGained", eventFocusGained);
  }

  @override
  Widget getWidget() {

    BoxConstraints constraints = BoxConstraints.tightFor();

    //if (maximumSize!=null) {
    //  constraints = BoxConstraints.loose(maximumSize);
    //}
    JVxData data = getIt.get<JVxScreen>().getData(cellEditor.linkReference.dataProvider, cellEditor.linkReference.referencedColumnNames);

    cellEditor.setData(data);

    return Container(
      constraints: constraints,
      color: Colors.grey[300],
      child: SizedBox(width: 100, child: cellEditor.getWidget())
    );
  }
}