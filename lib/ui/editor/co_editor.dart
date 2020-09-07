import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_flutterclient/model/filter.dart';
import 'package:jvx_flutterclient/utils/text_utils.dart';
import 'celleditor/co_number_cell_editor.dart';
import 'celleditor/co_text_cell_editor.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../../model/properties/hex_color.dart';
import '../component/component.dart';
import 'celleditor/co_cell_editor.dart';
import 'celleditor/co_referenced_cell_editor.dart';
import 'i_editor.dart';
import '../screen/so_component_data.dart';

class CoEditor extends Component implements IEditor {
  String dataProvider;
  String dataRow;
  String columnName;
  bool readonly = false;
  bool eventFocusGained = false;
  CoCellEditor _cellEditor;
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

  get cellEditor => _cellEditor;
  set cellEditor(CoCellEditor editor) {
    _cellEditor = editor;
    if (_cellEditor != null) {
      _cellEditor.onBeginEditing = onBeginEditing;
      _cellEditor.onEndEditing = onEndEditing;
      _cellEditor.onValueChanged = onValueChanged;
      _cellEditor.onFilter = onFilter;
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

  CoEditor(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  void onBeginEditing() {}

  void onValueChanged(dynamic value, [int index]) {
    bool isTextEditor =
        (cellEditor is CoTextCellEditor || cellEditor is CoNumberCellEditor);

    if (cellEditor is CoReferencedCellEditor) {
      data.setValues(
          context,
          (value is List) ? value : [value],
          (this.cellEditor as CoReferencedCellEditor)
              .linkReference
              .columnNames);
    } else {
      //Filter filter = Filter(
      //        columnNames: this.data.primaryKeyColumns,
      //        values: data.data.getRow(0, this.data.primaryKeyColumns));

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
    if (cellEditor is CoReferencedCellEditor) {
      (cellEditor as CoReferencedCellEditor)
          .data
          .filterData(context, value, this.name);
    }
  }

  void onEndEditing() {
    this.soComponentScreen.requestNext();
  }

  void onServerDataChanged() {
    this.cellEditor?.value = _data.getColumnData(context, columnName);
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
  }

  @override
  Widget getWidget() {
    if (_cellEditor == null) {
      return Container(
        margin: EdgeInsets.only(top: 9, bottom: 9),
        key: this.componentId,
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
        key: this.componentId,
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
