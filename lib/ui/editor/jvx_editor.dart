import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_choice_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/i_editor.dart';
import 'package:jvx_mobile_v3/ui/jvx_screen.dart';

class JVxEditor extends JVxComponent implements IEditor {
  Size maximumSize;
  String dataProvider;
  String dataRow;
  String columnName;
  bool readonly = false;
  bool eventFocusGained = false;
  JVxCellEditor cellEditor;
  int reload = -1;

  JVxEditor(Key componentId, BuildContext context) : super(componentId, context);

  void initData() {
    if (cellEditor?.linkReference!=null) {
      JVxData data = getIt.get<JVxScreen>().getData(cellEditor.dataProvider);
      if (data !=null) {
        cellEditor.setInitialData(data);
      }
    }
  }

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    maximumSize = changedComponent.getProperty<Size>(ComponentProperty.MAXIMUM_SIZE,null);
    dataProvider = changedComponent.getProperty<String>(ComponentProperty.DATA_PROVIDER, dataProvider);
    dataRow = changedComponent.getProperty<String>(ComponentProperty.DATA_ROW);
    columnName = changedComponent.getProperty<String>(ComponentProperty.COLUMN_NAME, columnName);
    readonly = changedComponent.getProperty<bool>(ComponentProperty.READONLY, readonly);
    eventFocusGained = changedComponent.getProperty<bool>(ComponentProperty.EVENT_FOCUS_GAINED, eventFocusGained);
  }

  @override
  Widget getWidget() {
    Color color = Colors.grey[200];
    if (cellEditor.linkReference!=null) {
      color = Colors.transparent;
      JVxData data = getIt.get<JVxScreen>().getData(cellEditor.linkReference.dataProvider, cellEditor.linkReference.referencedColumnNames);
      if (data !=null)
        cellEditor.setData(data);
    } else { 
      JVxData data = getIt.get<JVxScreen>().getData(this.dataProvider, [this.columnName], reload);
      reload = null;

      if (data !=null)
        cellEditor.setData(data);
    }

    if(this.cellEditor is JVxChoiceCellEditor) {
      return Container(child: this.cellEditor.getWidget());
    } else {  
    return Container(
      constraints: BoxConstraints.tightFor(),
      color: color,
      child: Container(width: 100, child: cellEditor.getWidget())
    );

    }
  }
}