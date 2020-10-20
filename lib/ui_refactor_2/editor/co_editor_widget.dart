import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen/component_screen_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen/so_component_data.dart';

import '../../model/changed_component.dart';
import '../../model/filter.dart';
import '../../model/properties/component_properties.dart';
import '../../model/properties/hex_color.dart';
import '../../utils/text_utils.dart';
import '../component/component_model.dart';
import '../component/component_widget.dart';
import 'celleditor/co_cell_editor_widget.dart';
import 'celleditor/co_number_cell_editor_widget.dart';
import 'celleditor/co_text_cell_editor_widget.dart';
import 'celleditor/co_referenced_cell_editor_widget.dart';
import 'editor_component_model.dart';

class CoEditorWidget extends ComponentWidget {
  final CoCellEditorWidget cellEditor;
  final SoComponentData data;

  CoEditorWidget({
    Key key,
    this.cellEditor,
    this.data,
    EditorComponentModel componentModel,
  }) : super(key: key, componentModel: componentModel);

  State<StatefulWidget> createState() => CoEditorWidgetState();

  static CoEditorWidgetState of(BuildContext context) =>
      context.findAncestorStateOfType<CoEditorWidgetState>();
}

class CoEditorWidgetState<T extends StatefulWidget>
    extends ComponentWidgetState<T> {
  String dataProvider;
  String dataRow;
  String columnName;
  bool readonly = false;
  bool eventFocusGained = false;
  CoCellEditorWidgetState _cellEditor;
  CoCellEditorWidget _cellEditorWidget;
  SoComponentData _data;
  Color cellEditorBackground;
  bool cellEditorEditable;
  String cellEditorFont;
  Color cellEditorForeground;
  int cellEditorHorizontalAlignment;
  String cellEditorPlaceholder;

  SoComponentData get data => _data;
  set data(SoComponentData data) {
    _data?.unregisterDataChanged(onServerDataChanged);
    _data = data;
    _data?.registerDataChanged(onServerDataChanged);

    this.cellEditor?.value = _data.getColumnData(context, columnName);
  }

  CoCellEditorWidgetState get cellEditor => _cellEditor;
  set cellEditor(CoCellEditorWidgetState editor) {
    _cellEditor = editor;
    if (editor != null) {
      _cellEditor.onBeginEditing = onBeginEditing;
      _cellEditor.onEndEditing = onEndEditing;
      _cellEditor.onValueChanged = onValueChanged;
      _cellEditor.onFilter = onFilter;
    }
  }

  CoCellEditorWidget get cellEditorWidget => _cellEditorWidget;
  set cellEditorWidget(CoCellEditorWidget cellEditorWidget) {
    if (cellEditorWidget != null) {
      _cellEditorWidget = cellEditorWidget;
    }
  }

  @override
  get preferredSize {
    if (super.preferredSize != null) return super.preferredSize;
    if (_cellEditor != null) return _cellEditor.preferredSize;
    return null;
  }

  @override
  get minimumSize {
    if (super.minimumSize != null) return super.minimumSize;
    if (_cellEditor != null) return _cellEditor.minimumSize;

    return null;
  }

  @override
  get maximumSize {
    if (super.maximumSize != null) return super.maximumSize;
    if (_cellEditor != null) return _cellEditor.maximumSize;

    return null;
  }

  /*@override
  get isPreferredSizeSet {
    return (preferredSize!=null) | (_cellEditor!=null && _cellEditor?.isPreferredSizeSet);
  }

  @override
  bool get isMinimumSizeSet {
    return super.isMinimumSizeSet | this.cellEditor?.isMinimumSizeSet;
  }

  @override
  bool get isMaximumSizeSet {
    return super.isMaximumSizeSet | this.cellEditor?.isMaximumSizeSet;
  }*/

  void onBeginEditing() {}

  void onEndEditing() {}

  void onDataChanged() {
    _data?.unregisterDataChanged(onServerDataChanged);
    _data = this.data;
    _data?.registerDataChanged(onServerDataChanged);

    this.cellEditor?.value = _data.getColumnData(context, columnName);
  }

  void onValueChanged(dynamic value, [int index]) {
    bool isTextEditor = (cellEditor is CoTextCellEditorWidgetState ||
        cellEditor is CoNumberCellEditorWidgetState);

    if (cellEditor is CoReferencedCellEditorWidgetState) {
      data.setValues(
          context,
          (value is List) ? value : [value],
          (this.cellEditor as CoReferencedCellEditorWidgetState)
              .linkReference
              .columnNames);
    } else {
      data.setValues(
          context,
          (value is List) ? value : [value],
          [columnName],
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
  }

  void onFilter(dynamic value) {
    /*
    if (cellEditor is CoReferencedCellEditor) {
      (cellEditor as CoReferencedCellEditor)
          .data
          .filterData(context, value, this.name);
    }
    */
  }

  void onServerDataChanged() {
    this.cellEditor?.value = _data.getColumnData(context, columnName);
  }

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);

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
  }

  void updateData() {
    String newColName =
        ((widget as CoEditorWidget).componentModel as EditorComponentModel)
            .columnName;

    if (newColName != null) this.columnName = newColName;

    ((widget as CoEditorWidget).componentModel as EditorComponentModel)
        .toUpdateData
        .forEach((updateData) {
      data = updateData;
    });

    ((widget as CoEditorWidget).componentModel as EditorComponentModel)
        .toUpdateData = Queue<SoComponentData>();

    if (this.data == null)
      this.data = ComponentScreenWidget.of(context).getComponentData(
          ((widget as CoEditorWidget).componentModel as EditorComponentModel)
              .dataProvider);

    if (this.data != null) this.onDataChanged();
  }

  @override
  void initState() {
    super.initState();

    if ((widget as CoEditorWidget).data != null) {
      this.data = (widget as CoEditorWidget).data;
    } else {
      dataProvider =
          ((widget as CoEditorWidget).componentModel as EditorComponentModel)
              .dataProvider;

      if (dataProvider != null)
        this.data =
            ComponentScreenWidget.of(context).getComponentData(dataProvider);
    }

    // this.updateData();

    // (widget as CoEditorWidget)
    //     .componentModel
    //     .addListener(() => setState(() => this.updateData()));

    _cellEditorWidget = (widget as CoEditorWidget).cellEditor;

    EditorComponentModel editorComponentModel =
        (widget as CoEditorWidget).componentModel as EditorComponentModel;

    if (!editorComponentModel.withChangedComponent) {
      this.cellEditorEditable = editorComponentModel.editable;
      this.cellEditorWidget?.cellEditorModel?.value =
          editorComponentModel.value;
      this.cellEditorWidget?.cellEditorModel?.indexInTable =
          editorComponentModel.indexInTable;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cellEditorWidget == null) {
      return Container(
        margin: EdgeInsets.only(top: 9, bottom: 9),
        width: TextUtils.getTextWidth(TextUtils.averageCharactersTextField,
            Theme.of(context).textTheme.button),
        height: 50,
        child: DecoratedBox(
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey)),
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
            ),
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      );
    }

    return Container(
        height: super.preferredSize != null ? super.preferredSize.height : null,
        width: super.preferredSize != null ? super.preferredSize.width : null,
        child: cellEditorWidget);
  }
}
