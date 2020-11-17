import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/referenced_cell_editor_model.dart';

import '../../../models/api/editor/cell_editor.dart';
import '../../../models/api/response/data/data_book.dart';
import 'cell_editor_model.dart';
import 'co_referenced_cell_editor_widget.dart';

class CoMultiLineCellEditorWidget extends CoReferencedCellEditorWidget {
  ReferencedCellEditorModel cellEditorModel;
  CoMultiLineCellEditorWidget(
      {CellEditor changedCellEditor, this.cellEditorModel})
      : super(
            changedCellEditor: changedCellEditor,
            cellEditorModel: cellEditorModel);

  @override
  State<StatefulWidget> createState() => CoMultiLineCellEditorWidgetState();
}

class CoMultiLineCellEditorWidgetState
    extends CoReferencedCellEditorWidgetState<CoMultiLineCellEditorWidget> {
  List<ListTile> _items = <ListTile>[];
  String selectedValue;

  void valueChanged(dynamic value) {
    this.value = value;
    this.onValueChanged(value);
  }

  List<ListTile> getItems(DataBook data) {
    List<ListTile> items = <ListTile>[];
    List<int> visibleColumnsIndex = <int>[];

    if (data != null && data.records.isNotEmpty) {
      data.columnNames.asMap().forEach((i, v) {
        if (widget.cellEditorModel.linkReference.referencedColumnNames
            .contains(v)) {
          visibleColumnsIndex.add(i);
        }
      });

      data.records.forEach((record) {
        record.asMap().forEach((i, c) {
          items.add(getItem(c.toString(), c.toString()));
        });
      });
    }

    if (items.length == 0) items.add(getItem('loading', 'Loading...'));

    return items;
  }

  ListTile getItem(String val, String text) {
    return ListTile(
      onTap: () {
        selectedValue = val;
        valueChanged(val);
      },
      selected: selectedValue == val ? true : false,
      title: Text(text),
    );
  }

  void setInitialData(DataBook data) {
    if (data != null &&
        data.selectedRow != null &&
        data.selectedRow >= 0 &&
        data.selectedRow < data.records.length &&
        data.columnNames != null &&
        data.columnNames.length > 0 &&
        widget.cellEditorModel.linkReference != null &&
        widget.cellEditorModel.linkReference.referencedColumnNames != null &&
        widget.cellEditorModel.linkReference.referencedColumnNames.length > 0) {
      int columnIndex = -1;
      data.columnNames.asMap().forEach((i, c) {
        if (widget.cellEditorModel.linkReference.referencedColumnNames[0] == c)
          columnIndex = i;
      });
      if (columnIndex >= 0) {
        value = data.records[data.selectedRow][columnIndex];
      }
    }

    this.setData(data);
  }

  void setData(DataBook data) {
    this._items = getItems(data);
  }

  @override
  Widget build(BuildContext context) {
    setEditorProperties(context);

    return Container(
      decoration: BoxDecoration(
          color: background != null
              ? background
              : Colors.white
                  .withOpacity(this.appState.applicationStyle?.controlsOpacity),
          borderRadius: BorderRadius.circular(
              this.appState.applicationStyle?.cornerRadiusEditors),
          border: borderVisible
              ? Border.all(color: Theme.of(context).primaryColor)
              : null),
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return _items[index];
        },
      ),
    );
  }
}
