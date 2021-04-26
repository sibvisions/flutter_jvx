import 'package:flutter/material.dart';

import '../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../models/api/response_objects/response_data/component/component.dart';
import '../../models/api/response_objects/response_data/data/filter.dart';
import '../component/model/component_model.dart';
import '../screen/core/so_component_data.dart';
import 'cell_editor/co_cell_editor_widget.dart';
import 'cell_editor/co_number_cell_editor_widget.dart';
import 'cell_editor/co_referenced_cell_editor_widget.dart';
import 'cell_editor/co_text_cell_editor_widget.dart';

typedef OnBeginEditing = void Function();
typedef OnEndEditing = void Function();
typedef OnDataChanged = void Function();
typedef OnValueChanged = void Function(dynamic value, [int? index]);
typedef OnFilter = void Function(dynamic value);
typedef OnServerDataChanged = void Function();

class EditorComponentModel extends ComponentModel {
  String? dataProvider;
  String? dataRow;
  String? columnName;
  bool readOnly = false;
  bool eventFocusGained = false;
  SoComponentData? _data;
  Color? cellEditorBackground;
  bool? cellEditorEditable;
  String? cellEditorFont;
  Color? cellEditorForeground;
  int? cellEditorHorizontalAlignment;
  String? cellEditorPlaceholder;
  bool _withChangedComponent = true;

  CoCellEditorWidget? _cellEditorWidget;

  int? indexInTable;
  Function(int index)? onRowTapped;
  bool editable = true;

  OnBeginEditing? onBeginEditingCallback;
  OnEndEditing? onEndEditingCallback;
  OnDataChanged? onDataChangedCallback;
  OnValueChanged? onValueChangedCallback;
  OnFilter? onFilterCallback;
  OnServerDataChanged? onServerDataChangedCallback;

  SoComponentData? get data => _data;

  set data(SoComponentData? data) {
    _data?.unregisterDataChanged(onServerDataChanged);
    _data?.unregisterSelectedRowChanged(onSelectedRowChanged);
    _data = data;
    _data?.registerDataChanged(onServerDataChanged);
    _data?.registerSelectedRowChanged(onSelectedRowChanged);

    if (cellEditor != null && !cellEditor!.cellEditorModel.isTableView) {
      cellEditor?.cellEditorModel.cellEditorValue =
          _data?.getColumnData(null, columnName!);

      cellEditor!.cellEditorModel.columnName = columnName;
      cellEditor!.cellEditorModel.data = data;
    }
  }

  CoCellEditorWidget? get cellEditor => _cellEditorWidget;

  set cellEditor(CoCellEditorWidget? cellEditorWidget) {
    _cellEditorWidget = cellEditorWidget;

    _cellEditorWidget?.cellEditorModel.onBeginEditing = onBeginEditing;
    _cellEditorWidget?.cellEditorModel.onEndEditing = onEndEditing;
    _cellEditorWidget?.cellEditorModel.onValueChanged = onValueChanged;
    _cellEditorWidget?.cellEditorModel.onFilter = onFilter;

    setEditorProperties();
  }

  @override
  get preferredSize {
    if (cellEditor?.cellEditorModel.preferredSize != null)
      return cellEditor?.cellEditorModel.preferredSize;
    return super.preferredSize;
  }

  @override
  get minimumSize {
    if (cellEditor?.cellEditorModel.minimumSize != null)
      return cellEditor?.cellEditorModel.minimumSize;

    return super.minimumSize;
  }

  @override
  get maximumSize {
    if (cellEditor?.cellEditorModel.maximumSize != null)
      return cellEditor?.cellEditorModel.maximumSize;

    return super.maximumSize;
  }

  bool get withChangedComponent => _withChangedComponent;

  EditorComponentModel({required ChangedComponent changedComponent})
      : super(changedComponent: changedComponent) {
    if (dataProvider == null) {
      dataProvider = changedComponent.getProperty<String>(
          ComponentProperty.DATA_BOOK, dataProvider);

      dataRow = changedComponent.getProperty<String>(
          ComponentProperty.DATA_ROW, dataRow);

      if (dataProvider == null) dataProvider = dataRow;
    }
  }

  EditorComponentModel.withoutChangedComponent(
    dynamic value,
    String? colName,
    int? index,
    Function(int index)? onRowTapped,
    bool editable,
  ) : super(changedComponent: ChangedComponent()) {
    _withChangedComponent = false;
    if (cellEditor != null) cellEditor!.cellEditorModel.cellEditorValue = value;
    columnName = colName;
    this.onRowTapped = onRowTapped;
    this.editable = editable;
    indexInTable = index;
  }

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    columnName = changedComponent.getProperty<String>(
        ComponentProperty.COLUMN_NAME, columnName);
    readOnly = changedComponent.getProperty<bool>(
        ComponentProperty.READONLY, readOnly)!;
    eventFocusGained = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_FOCUS_GAINED, eventFocusGained)!;
    dataProvider = changedComponent.getProperty<String>(
        ComponentProperty.DATA_PROVIDER, dataProvider);

    cellEditorEditable = changedComponent.getProperty<bool>(
        ComponentProperty.CELL_EDITOR___EDITABLE___, cellEditorEditable);
    cellEditorPlaceholder = changedComponent.getProperty<String>(
        ComponentProperty.CELL_EDITOR___PLACEHOLDER___, cellEditorPlaceholder);

    cellEditorBackground = changedComponent.getProperty<Color>(
        ComponentProperty.CELL_EDITOR___BACKGROUND___, cellEditorBackground);
    cellEditorForeground = changedComponent.getProperty<Color>(
        ComponentProperty.CELL_EDITOR___FOREGROUND___, cellEditorForeground);
    cellEditorHorizontalAlignment = changedComponent.getProperty<int>(
        ComponentProperty.CELL_EDITOR___HORIZONTAL_ALIGNMENT___,
        cellEditorHorizontalAlignment);
    cellEditorFont = changedComponent.getProperty<String>(
        ComponentProperty.CELL_EDITOR___FONT___, cellEditorFont);

    if (dataProvider == null)
      dataProvider = changedComponent.getProperty<String>(
          ComponentProperty.DATA_BOOK, dataProvider);

    dataRow = changedComponent.getProperty<String>(
        ComponentProperty.DATA_ROW, dataRow);

    if (dataProvider == null) dataProvider = dataRow;

    setEditorProperties();

    super.updateProperties(context, changedComponent);
  }

  void onBeginEditing() {
    if (onBeginEditingCallback != null) {
      onBeginEditingCallback!();
    }
  }

  void onEndEditing() {
    if (onEndEditingCallback != null) {
      onEndEditingCallback!();
    }
  }

  void onDataChanged(BuildContext context) {
    _data?.unregisterDataChanged(onServerDataChanged);
    _data = data;
    _data?.registerDataChanged(onServerDataChanged);

    cellEditor?.cellEditorModel.cellEditorValue =
        _data?.getColumnData(context, columnName!);

    if (onDataChangedCallback != null) {
      onDataChangedCallback!();
    }
  }

  void onValueChanged(BuildContext context, dynamic value, [int? index]) {
    bool isTextEditor = (cellEditor is CoTextCellEditorWidget ||
        cellEditor is CoNumberCellEditorWidget);

    if (cellEditor is CoReferencedCellEditorWidget) {
      data!.setValues(
          context,
          (value is List) ? value : [value],
          (this.cellEditor as CoReferencedCellEditorWidget)
              .cellEditorModel
              .linkReference!
              .columnNames);
    } else {
      data!.setValues(
          context,
          (value is List) ? value : [value],
          [columnName],
          index != null && index > -1
              ? Filter(
                  columnNames: data!.primaryKeyColumns,
                  values: data?.data
                      ?.getRow(index, data?.metaData?.primaryKeyColumns))
              : null,
          isTextEditor);
    }

    if (this.onValueChangedCallback != null) {
      onValueChangedCallback!(value, index);
    }
  }

  void onFilter(dynamic value) {
    if (cellEditor is CoReferencedCellEditorWidget) {
      (cellEditor as CoReferencedCellEditorWidget)
          .cellEditorModel
          .referencedData
          ?.filterData(value, this.name);
    }
    if (this.onFilterCallback != null) {
      onFilterCallback!(value);
    }
  }

  void onServerDataChanged(BuildContext context) {
    if (withChangedComponent)
      cellEditor?.cellEditorModel.cellEditorValue =
          _data?.getColumnData(context, columnName!);
    if (onServerDataChangedCallback != null) {
      onServerDataChangedCallback!();
    }
  }

  void onSelectedRowChanged(BuildContext context, dynamic selectedRow) {
    if (withChangedComponent)
      cellEditor?.cellEditorModel.cellEditorValue =
          _data?.getColumnData(context, columnName!);
    if (onServerDataChangedCallback != null) {
      onServerDataChangedCallback!();
    }
  }

  void setEditorProperties() {
    if (cellEditor != null) {
      cellEditor!.cellEditorModel.editable = cellEditorEditable ?? editable;
      cellEditor!.cellEditorModel.backgroundColor = cellEditorBackground;
      cellEditor!.cellEditorModel.foregroundColor = cellEditorForeground;
      cellEditor!.cellEditorModel.placeholder = cellEditorPlaceholder;
      cellEditor!.cellEditorModel.horizontalAlignment =
          cellEditorHorizontalAlignment ?? 0;
      cellEditor!.cellEditorModel.font = cellEditorFont;
      cellEditor!.cellEditorModel.indexInTable = indexInTable ?? -1;
    }
  }
}
