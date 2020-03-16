import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../../model/properties/hex_color.dart';
import '../../ui/component/jvx_component.dart';
import '../../ui/editor/celleditor/jvx_cell_editor.dart';
import '../../ui/editor/celleditor/jvx_referenced_cell_editor.dart';
import '../../ui/editor/i_editor.dart';
import '../../ui/screen/component_data.dart';

class JVxEditor extends JVxComponent implements IEditor {
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
    if (super.preferredSize != null) return super.preferredSize;

    return _cellEditor.preferredSize;
  }

  @override
  get minimumSize {
    if (super.minimumSize != null) return super.minimumSize;

    return _cellEditor.minimumSize;
  }

  @override
  get maximumSize {
    if (super.maximumSize != null) return super.maximumSize;

    return _cellEditor.maximumSize;
  }

  @override
  get isPreferredSizeSet {
    return super.isPreferredSizeSet | this.cellEditor?.isPreferredSizeSet;
  }

  @override
  bool get isMinimumSizeSet {
    return super.isMinimumSizeSet | this.cellEditor?.isMinimumSizeSet;
  }

  @override
  bool get isMaximumSizeSet {
    return super.isMaximumSizeSet | this.cellEditor?.isMaximumSizeSet;
  }

  JVxEditor(Key componentId, BuildContext context)
      : super(componentId, context);

  void onBeginEditing() {}

  void onValueChanged(dynamic value) {
    if (cellEditor is JVxReferencedCellEditor) {
      data.setValues(
          context,
          (value is List) ? value : [value],
          (this.cellEditor as JVxReferencedCellEditor)
              .linkReference
              .columnNames);
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
  }

  @override
  Widget getWidget() {
    if (reload != null) {
      this.cellEditor?.value =
          data.getColumnData(context, this.columnName, this.reload);
      this.reload = null;
    }

    return Container(
        height: super.preferredSize != null ? super.preferredSize.height : null,
        width: super.preferredSize != null ? super.preferredSize.width : null,
        child: cellEditor.getWidget(
            editable: cellEditorEditable,
            background: cellEditorBackground,
            foreground: cellEditorForeground,
            placeholder: cellEditorPlaceholder,
            horizontalAlignment: cellEditorHorizontalAlignment,
            font: cellEditorFont));
  }
}
