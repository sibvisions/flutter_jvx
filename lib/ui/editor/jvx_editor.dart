import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_choice_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_referenced_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/i_editor.dart';
import 'package:jvx_mobile_v3/ui/screen/screen.dart';

//typedef EndEditing<T> = void Function(T value);
//typedef VoidCallback BeginEditing = void Function();

class JVxEditor extends JVxComponent implements IEditor {
  Size maximumSize;
  String dataProvider;
  String dataRow;
  String columnName;
  bool readonly = false;
  bool eventFocusGained = false;
  JVxCellEditor _cellEditor;
  int reload = -1;

  get cellEditor => _cellEditor;
  set cellEditor(JVxCellEditor editor) {
    _cellEditor = editor;
    _cellEditor.onBeginEditing = onBeginEditing;
    _cellEditor.onEndEditing = onEndEditing;
    _cellEditor.onValueChanged = onValueChanged;
  } 

  JVxEditor(Key componentId, BuildContext context) : super(componentId, context);

  void onBeginEditing() {
    
  }

  void onValueChanged(dynamic value) {
    List<dynamic> columnNames = [columnName];

    if (_cellEditor is JVxReferencedCellEditor)
      columnNames = (_cellEditor as JVxReferencedCellEditor).linkReference.columnNames;

    getIt
        .get<JVxScreen>("screen")
        .setValues(dataProvider, columnNames, [value]);
  }

  void onEndEditing() {
    
  }

  void initData() {
    if (_cellEditor is JVxReferencedCellEditor && (_cellEditor as JVxReferencedCellEditor)?.linkReference!=null) {
      JVxData data = getIt.get<JVxScreen>("screen").getData(cellEditor.dataProvider);
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

    BoxConstraints constraints = BoxConstraints.tightFor();

    if (maximumSize!=null)
      constraints = BoxConstraints.loose(maximumSize);

    Color color = Colors.grey[200];
    if (_cellEditor is JVxReferencedCellEditor && (_cellEditor as JVxReferencedCellEditor).linkReference!=null) {
      color = Colors.transparent;
      JVxData data = getIt.get<JVxScreen>("screen").getData(
        (_cellEditor as JVxReferencedCellEditor).linkReference.dataProvider, 
        (_cellEditor as JVxReferencedCellEditor).linkReference.referencedColumnNames);
      if (data !=null)
        cellEditor.setData(data);
    } else { 
      JVxData data = getIt.get<JVxScreen>("screen").getData(this.dataProvider, [this.columnName], reload);
      reload = null;

      if (data !=null)
        cellEditor.setData(data);
    }

    if(this.cellEditor is JVxChoiceCellEditor) {
      return Container(child: this.cellEditor.getWidget());
    } else {  
    return Container(
      constraints: constraints,
      color: color,
      child: Container(width: 100, child: cellEditor.getWidget())
    );

    }
  }
}