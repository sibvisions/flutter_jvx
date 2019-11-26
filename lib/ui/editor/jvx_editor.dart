import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_choice_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_referenced_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/i_editor.dart';
import 'package:jvx_mobile_v3/ui/screen/component_data.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

class JVxEditor extends JVxComponent implements IEditor {
  Size maximumSize;
  String dataProvider;
  String dataRow;
  String columnName;
  bool readonly = false;
  bool eventFocusGained = false;
  JVxCellEditor _cellEditor;
  ComponentData _data;
  int reload;

  ComponentData get data => _data;
  set data(ComponentData data) {
    _data?.unregisterDataChanged(onServerDataChanged);
    _data = data;
    _data?.registerDataChanged(onServerDataChanged);

    this.cellEditor?.value = _data.getColumnData(context, columnName, null);
  }

  get cellEditor => _cellEditor;
  set cellEditor(JVxCellEditor editor) {
    _cellEditor = editor;
    _cellEditor.onBeginEditing = onBeginEditing;
    _cellEditor.onEndEditing = onEndEditing;
    _cellEditor.onValueChanged = onValueChanged;
  }

  JVxEditor(Key componentId, BuildContext context)
      : super(componentId, context);

  void onBeginEditing() {}

  void onValueChanged(dynamic value) {
    if (this.cellEditor is JVxReferencedCellEditor)
      data.setValues(context, [value]);
    else
      data.setValues(context, [value], [columnName]);
  }

  void onEndEditing() {}

  void onServerDataChanged() {
    this.cellEditor?.value = _data.getColumnData(context, columnName, null);
  }

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    maximumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MAXIMUM_SIZE, null);
    dataProvider = changedComponent.getProperty<String>(
        ComponentProperty.DATA_PROVIDER, dataProvider);
    dataRow = changedComponent.getProperty<String>(ComponentProperty.DATA_ROW);
    columnName = changedComponent.getProperty<String>(
        ComponentProperty.COLUMN_NAME, columnName);
    readonly = changedComponent.getProperty<bool>(
        ComponentProperty.READONLY, readonly);
    eventFocusGained = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_FOCUS_GAINED, eventFocusGained);
    try {
      this.reload = changedComponent.getProperty<int>(ComponentProperty.RELOAD);
    } catch (e) {
      bool rel = changedComponent.getProperty<bool>(ComponentProperty.RELOAD);
      if (rel != null && rel) this.reload = -1;
    }
  }

  @override
  Widget getWidget() {
    if (reload == -1) {
      this.cellEditor?.value =
          data.getColumnData(context, this.columnName, this.reload);
      this.reload = null;
    }
    BoxConstraints constraints = BoxConstraints.tightFor();

    if (maximumSize != null) constraints = BoxConstraints.loose(maximumSize);

    Color color = Colors.transparent; // Colors.grey[200];

    if (this.cellEditor is JVxChoiceCellEditor) {
      return Container(child: this.cellEditor.getWidget());
    } else {
      return Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5),   
            border: Border.all(color: UIData.ui_kit_color_2)    
          ),
          constraints: constraints,
          //color: color,
          child: Container(width: 100, child: cellEditor.getWidget()));
    }
  }
}
