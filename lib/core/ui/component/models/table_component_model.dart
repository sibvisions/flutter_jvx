import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/models/api/editor/cell_editor.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/models/cell_editor_model.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/models/checkbox_cell_editor_model.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/models/choice_cell_editor_model.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/models/date_cell_editor_model.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/models/linked_cell_editor_model.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/models/referenced_cell_editor_model.dart';
import 'package:jvx_flutterclient/core/ui/screen/component_screen_widget.dart';

import '../../../models/api/component/changed_component.dart';
import '../../../models/api/component/component_properties.dart';
import '../../../models/api/response/data/data_book.dart';
import '../../../models/api/response/meta_data/data_book_meta_data_column.dart';
import '../../editor/co_editor_widget.dart';
import '../../editor/editor_component_model.dart';
import '../../screen/so_component_creator.dart';
import '../../screen/so_component_data.dart';
import '../component_widget.dart';
import '../so_table_column_calculator.dart';

typedef OnSelectedRowChanged = void Function(dynamic selectedRow);

class TableComponentModel extends EditorComponentModel {
  // visible column names
  List<String> columnNames = <String>[];

  // column labels for header
  List<String> columnLabels = <String>[];

  // the show vertical lines flag.
  bool showVerticalLines = false;

  // the show horizontal lines flag.
  bool showHorizontalLines = false;

  // the show table header flag
  bool tableHeaderVisible = true;

  // table editable
  bool editable = true;

  int selectedRow;

  int pageSize = 100;
  double fetchMoreItemOffset = 20;
  List<SoTableColumn> columnInfo;
  var tapPosition;
  SoComponentCreator componentCreator;
  bool autoResize = false;
  bool hasHorizontalScroller = false;
  Function(int index) onRowTapped;

  OnSelectedRowChanged onSelectedRowChangedCallback;

  // Properties for lazy dropdown
  dynamic value;

  Map<String, CoEditorWidget> _editors = <String, CoEditorWidget>{};

  TextStyle get headerStyleMandatory {
    return this.headerTextStyle;
  }

  TextStyle get headerTextStyle {
    return this.fontStyle.copyWith(fontWeight: FontWeight.bold);
  }

  TextStyle get itemTextStyle {
    return this.fontStyle;
  }

  @override
  get preferredSize {
    if (super.preferredSize != null) return super.preferredSize;
    return Size(300, 300);
  }

  @override
  get minimumSize {
    if (super.minimumSize != null) return super.minimumSize;
    return Size(300, 100);
  }

  @override
  bool get isPreferredSizeSet => true;
  @override
  bool get isMinimumSizeSet => true;
  @override
  bool get isMaximumSizeSet => maximumSize != null;

  @override
  set data(SoComponentData data) {
    super.data?.unregisterDataChanged(onServerDataChanged);
    super.data?.unregisterSelectedRowChanged(onSelectedRowChanged);
    super.data = data;
    super.data?.registerDataChanged(onServerDataChanged);
    super.data?.registerSelectedRowChanged(onSelectedRowChanged);
  }

  TableComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  TableComponentModel.withoutChangedComponent(
      dynamic value,
      String columnName,
      Function onRowTapped,
      bool editable,
      bool tableHeaderVisible,
      bool autoResize,
      List<String> columnNames,
      List<String> columnLabels)
      : super.withoutChangedComponent(
            value, columnName, null, onRowTapped, editable) {
    this.tableHeaderVisible = tableHeaderVisible;
    this.editable = editable;
    this.autoResize = autoResize;
    this.columnNames = columnNames;
    this.onRowTapped = onRowTapped;
    this.indexInTable = indexInTable;
    this.columnLabels = columnLabels;
  }

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    showVerticalLines = changedComponent.getProperty<bool>(
        ComponentProperty.SHOW_VERTICAL_LINES, showVerticalLines);
    showHorizontalLines = changedComponent.getProperty<bool>(
        ComponentProperty.SHOW_HORIZONTAL_LINES, showHorizontalLines);
    tableHeaderVisible = changedComponent.getProperty<bool>(
        ComponentProperty.TABLE_HEADER_VISIBLE, tableHeaderVisible);
    columnNames = changedComponent.getProperty<List<String>>(
        ComponentProperty.COLUMN_NAMES, columnNames);
    columnLabels = changedComponent.getProperty<List<String>>(
        ComponentProperty.COLUMN_LABELS, columnLabels);
    autoResize = changedComponent.getProperty<bool>(
        ComponentProperty.AUTO_RESIZE, autoResize);
    editable = changedComponent.getProperty<bool>(
        ComponentProperty.AUTO_RESIZE, editable);

    if (this.dataProvider == null)
      this.dataProvider = changedComponent.getProperty<String>(
          ComponentProperty.DATA_BOOK, this.dataProvider);

    int newSelectedRow =
        changedComponent.getProperty<int>(ComponentProperty.SELECTED_ROW);
    if (newSelectedRow != null &&
        newSelectedRow >= 0 &&
        newSelectedRow != selectedRow &&
        this.data != null &&
        this.data?.data != null)
      this.data?.updateSelectedRow(context, newSelectedRow, true);

    selectedRow = changedComponent.getProperty<int>(
        ComponentProperty.SELECTED_ROW, selectedRow);

    super.updateProperties(context, changedComponent);
  }

  void onSelectedRowChanged(dynamic selectedRow) {
    if (this.onSelectedRowChangedCallback != null) {
      this.onSelectedRowChangedCallback(selectedRow);
    }
  }

  String _getEditorIdentifier(String columnName, int index) {
    return '${columnName}_$index';
  }

  CoEditorWidget getEditorForColumn(
      BuildContext context, String text, String columnName, int index) {
    DataBookMetaDataColumn column = this.data?.getMetaDataColumn(columnName);

    if (column != null && index >= 0) {
      if (_editors[_getEditorIdentifier(columnName, index)] == null) {
        CoEditorWidget editor = this.componentCreator.createEditorForTable(
              column?.cellEditor,
              text,
              this.editable,
              index,
              this.data,
              columnName,
            );
        if (editor != null) {
          if (editor.cellEditor.cellEditorModel is LinkedCellEditorModel) {
            (editor.cellEditor.cellEditorModel as LinkedCellEditorModel)
                    .referencedData =
                ComponentScreenWidget.of(context).getComponentData(editor
                    .cellEditor
                    .cellEditorModel
                    .cellEditor
                    .linkReference
                    .dataProvider);
          }

          _editors[_getEditorIdentifier(columnName, index)] = editor;
          return editor;
        }
      } else {
        _editors[_getEditorIdentifier(columnName, index)]
            .cellEditor
            .cellEditorModel
            .cellEditorValue = text;
        return _editors[_getEditorIdentifier(columnName, index)];
      }
    }
    return null;
  }
}
