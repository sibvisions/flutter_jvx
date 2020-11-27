import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/models/api/response/data/filter.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/co_number_cell_editor_widget.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/co_referenced_cell_editor_widget.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/co_text_cell_editor_widget.dart';
import 'package:jvx_flutterclient/core/ui/screen/so_component_data.dart';
import 'package:jvx_flutterclient/core/utils/theme/hex_color.dart';

import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../component/models/component_model.dart';
import 'celleditor/co_cell_editor_widget.dart';

typedef OnBeginEditing = void Function();
typedef OnEndEditing = void Function();
typedef OnDataChanged = void Function();
typedef OnValueChanged = void Function(dynamic value, [int index]);
typedef OnFilter = void Function(dynamic value);
typedef OnServerDataChanged = void Function();

class EditorComponentModel extends ComponentModel {
  String dataProvider;
  String dataRow;
  String columnName;
  bool readonly = false;
  bool eventFocusGained = false;
  CoCellEditorWidget _cellEditorWidget;
  SoComponentData _data;
  Color cellEditorBackground;
  bool cellEditorEditable;
  String cellEditorFont;
  Color cellEditorForeground;
  int cellEditorHorizontalAlignment;
  String cellEditorPlaceholder;
  bool _withChangedComponent = true;

  int indexInTable;
  Function(int index) onRowTapped;
  bool editable;

  OnBeginEditing onBeginEditingCallback;
  OnEndEditing onEndEditingCallback;
  OnDataChanged onDataChangedCallback;
  OnValueChanged onValueChangedCallback;
  OnFilter onFilterCallback;
  OnServerDataChanged onServerDataChangedCallback;

  SoComponentData get data => _data;

  set data(SoComponentData data) {
    _data?.unregisterDataChanged(onServerDataChanged);
    _data = data;
    _data?.registerDataChanged(onServerDataChanged);
  }

  CoCellEditorWidget get cellEditor => _cellEditorWidget;
  set cellEditor(CoCellEditorWidget cellEditorWidget) {
    _cellEditorWidget = cellEditorWidget;
    if (cellEditorWidget != null) {
      _cellEditorWidget.cellEditorModel.onBeginEditing = onBeginEditing;
      _cellEditorWidget.cellEditorModel.onEndEditing = onEndEditing;
      _cellEditorWidget.cellEditorModel.onValueChanged = onValueChanged;
      _cellEditorWidget.cellEditorModel.onFilter = onFilter;
    }
  }

  @override
  get preferredSize {
    if (cellEditor?.cellEditorModel?.preferredSize != null)
      return cellEditor.cellEditorModel.preferredSize;
    return super.preferredSize;
  }

  @override
  get minimumSize {
    if (cellEditor?.cellEditorModel?.minimumSize != null)
      return cellEditor.cellEditorModel.minimumSize;

    return super.minimumSize;
  }

  @override
  get maximumSize {
    if (cellEditor?.cellEditorModel?.maximumSize != null)
      return cellEditor.cellEditorModel.maximumSize;

    return super.maximumSize;
  }

  bool get withChangedComponent => _withChangedComponent;

  EditorComponentModel(ChangedComponent changedComponent)
      : super(changedComponent) {
    if (changedComponent != null) {
      if (dataProvider == null)
        dataProvider = changedComponent.getProperty<String>(
            ComponentProperty.DATA_BOOK, dataProvider);

      dataRow =
          changedComponent.getProperty<String>(ComponentProperty.DATA_ROW);

      if (dataProvider == null) dataProvider = dataRow;
    }
  }

  EditorComponentModel.withoutChangedComponent(
    dynamic value,
    String columnName,
    int indexInTable,
    Function onRowTapped,
    bool editable,
  ) : super(null) {
    this._withChangedComponent = false;
    if (this.cellEditor != null)
      this.cellEditor.cellEditorModel.cellEditorValue = value;
    this.columnName = columnName;
    this.onRowTapped = onRowTapped;
    this.editable = editable;
    this.indexInTable = indexInTable;
  }

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    columnName = changedComponent.getProperty<String>(
        ComponentProperty.COLUMN_NAME, columnName);
    readonly = changedComponent.getProperty<bool>(
        ComponentProperty.READONLY, readonly);
    eventFocusGained = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_FOCUS_GAINED, eventFocusGained);
    dataProvider =
        changedComponent.getProperty<String>(ComponentProperty.DATA_PROVIDER);

    cellEditorEditable = changedComponent.getProperty<bool>(
        ComponentProperty.CELL_EDITOR___EDITABLE___, cellEditorEditable);
    cellEditorPlaceholder = changedComponent.getProperty<String>(
        ComponentProperty.CELL_EDITOR___PLACEHOLDER___, cellEditorPlaceholder);

    print(
        '-------------- PLACEHOLDER FOR ${cellEditor.runtimeType} : $cellEditorPlaceholder');

    cellEditorBackground = changedComponent.getProperty<HexColor>(
        ComponentProperty.CELL_EDITOR___BACKGROUND___, cellEditorBackground);
    cellEditorForeground = changedComponent.getProperty<HexColor>(
        ComponentProperty.CELL_EDITOR___FOREGROUND___, cellEditorForeground);
    cellEditorHorizontalAlignment = changedComponent.getProperty<int>(
        ComponentProperty.CELL_EDITOR___HORIZONTAL_ALIGNMENT___,
        cellEditorHorizontalAlignment);
    cellEditorFont = changedComponent.getProperty<String>(
        ComponentProperty.CELL_EDITOR___FONT___, cellEditorFont);

    if (dataProvider == null)
      dataProvider = changedComponent.getProperty<String>(
          ComponentProperty.DATA_BOOK, dataProvider);

    dataRow = changedComponent.getProperty<String>(ComponentProperty.DATA_ROW);

    if (dataProvider == null) dataProvider = dataRow;

    super.updateProperties(context, changedComponent);
  }

  void onBeginEditing() {
    if (this.onBeginEditingCallback != null) {
      this.onBeginEditingCallback();
    }
  }

  void onEndEditing() {
    if (this.onEndEditingCallback != null) {
      this.onEndEditingCallback();
    }
  }

  void onDataChanged(BuildContext context) {
    _data?.unregisterDataChanged(onServerDataChanged);
    _data = this.data;
    _data?.registerDataChanged(onServerDataChanged);

    this.cellEditor?.cellEditorModel?.value =
        _data.getColumnData(context, columnName);

    if (this.onDataChangedCallback != null) {
      this.onDataChangedCallback();
    }
  }

  void onValueChanged(BuildContext context, dynamic value, [int index]) {
    bool isTextEditor = (cellEditor is CoTextCellEditorWidget ||
        cellEditor is CoNumberCellEditorWidget);

    if (cellEditor is CoReferencedCellEditorWidget) {
      data.setValues(
          context,
          (value is List) ? value : [value],
          (this.cellEditor as CoReferencedCellEditorWidget)
              .cellEditorModel
              .linkReference
              .columnNames);
    } else {
      data.setValues(
          context,
          (value is List) ? value : [value],
          [this.columnName],
          index != null
              ? Filter(
                  columnNames: this.data.primaryKeyColumns,
                  values: this
                      .data
                      .data
                      .getRow(index, this.data.metaData.primaryKeyColumns))
              : null,
          isTextEditor);
    }

    if (this.onValueChangedCallback != null) {
      this.onValueChangedCallback(value, index);
    }
  }

  void onFilter(dynamic value) {
    /*
    if (cellEditor is CoReferencedCellEditor) {
      (cellEditor as CoReferencedCellEditor)
          .data
          .filterData(context, value, this.name);
    }
    */
    if (this.onFilterCallback != null) {
      this.onFilterCallback(value);
    }
  }

  void onServerDataChanged(BuildContext context) {
    if (context != null)
      this.cellEditor?.cellEditorModel?.value =
          _data.getColumnData(context, columnName);
    if (this.onServerDataChangedCallback != null) {
      this.onServerDataChangedCallback();
    }
  }

  void setEditorProperties(BuildContext context) {
    this.cellEditor.cellEditorModel.editable = this.cellEditorEditable;
    this.cellEditor.cellEditorModel.background = this.cellEditorBackground;
    this.cellEditor.cellEditorModel.foreground = this.cellEditorForeground;
    this.cellEditor.cellEditorModel.placeholder = this.cellEditorPlaceholder;
    this.cellEditor.cellEditorModel.horizontalAlignment =
        this.cellEditorHorizontalAlignment;
    this.cellEditor.cellEditorModel.font = this.cellEditorFont;
    this.cellEditor.cellEditorModel.indexInTable = this.indexInTable;
  }
}
