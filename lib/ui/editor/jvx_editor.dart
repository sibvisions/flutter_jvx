import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/model/properties/hex_color.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_referenced_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/i_editor.dart';
import 'package:jvx_mobile_v3/ui/screen/component_data.dart';

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
  Color cellEditorBackground;
  bool cellEditorEditable;
  String cellEditorFont;
  Color cellEditorForeground;
  int cellEditorHorizontalAlignment;
  String cellEditorPlaceholder;

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
    _cellEditor.onFilter = onFilter;
  }

  @override
  get preferredSize {
    return _cellEditor.preferredSize;
  }

  @override
  get minimumSize {
    return _cellEditor.minimumSize;
  }

  @override
  get isPreferredSizeSet {
    if (this._cellEditor!=null) return this._cellEditor.isPreferredSizeSet;
    return false;
  }

  @override
  bool get isMinimumSizeSet {
    if (this._cellEditor!=null) return this._cellEditor.isMinimumSizeSet;
    return false;
  }

  @override
  bool get isMaximumSizeSet {
    if (this._cellEditor!=null) return this._cellEditor.isMaximumSizeSet;
    return false;
  }

  JVxEditor(Key componentId, BuildContext context)
      : super(componentId, context);

  void onBeginEditing() {}

  void onValueChanged(dynamic value) {
    if (cellEditor is JVxReferencedCellEditor) {
      data.setValues(context, (value is List) ? value : [value], (this.cellEditor as JVxReferencedCellEditor).linkReference.columnNames);
    } else {
      data.setValues(context, (value is List) ? value : [value], [columnName]);
    }
  }

  void onFilter(dynamic value) {
    if (cellEditor is JVxReferencedCellEditor) {
      (cellEditor as JVxReferencedCellEditor)
          .data
          .filterData(context, value, this.name);
    }
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

    cellEditorEditable = changedComponent.getProperty<bool>(
        ComponentProperty.CELL_EDITOR__EDITABLE, cellEditorEditable);
    cellEditorPlaceholder = changedComponent.getProperty<String>(
        ComponentProperty.CELL_EDITOR__PLACEHOLDER, cellEditorPlaceholder);
    cellEditorBackground = changedComponent.getProperty<HexColor>(
        ComponentProperty.CELL_EDITOR__BACKGROUND, cellEditorBackground);
    cellEditorForeground = changedComponent.getProperty<HexColor>(
        ComponentProperty.CELL_EDITOR__FOREGROUND, cellEditorForeground);
    cellEditorHorizontalAlignment = changedComponent.getProperty<int>(
        ComponentProperty.CELL_EDITOR__HORIZONTAL_ALIGNMENT,
        cellEditorHorizontalAlignment);
    cellEditorFont = changedComponent.getProperty<String>(
        ComponentProperty.CELL_EDITOR__FONT, cellEditorFont);
    try {
      this.reload = changedComponent.getProperty<int>(ComponentProperty.RELOAD);
    } catch (e) {
      bool rel = changedComponent.getProperty<bool>(ComponentProperty.RELOAD);
      if (rel != null && rel) this.reload = -1;
    }

    // _cellEditor.background = cellEditorBackground;
    // _cellEditor.foreground = cellEditorForeground;
    // _cellEditor.horizontalAlignment = cellEditorHorizontalAlignment;
    // _cellEditor.font = cellEditorFont;
    // _cellEditor.placeholder = cellEditorPlaceholder;
    // _cellEditor.editable = cellEditorEditable;
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
    return Container( 
      child: cellEditor.getWidget(
        editable: cellEditorEditable,
        background: cellEditorBackground,
        foreground: cellEditorForeground,
        placeholder: cellEditorPlaceholder,
        horizontalAlignment: cellEditorHorizontalAlignment,
        font: cellEditorFont));
  }
}