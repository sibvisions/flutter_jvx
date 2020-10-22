import 'package:flutter/material.dart';

import '../../../model/api/response/data/data_book.dart';
import '../../../model/cell_editor.dart';
import '../../../utils/globals.dart' as globals;
import '../../../utils/uidata.dart';
import 'cell_editor_model.dart';
import 'co_referenced_cell_editor_widget.dart';

class CoMultiLineCellEditorWidget extends CoReferencedCellEditorWidget {
  CoMultiLineCellEditorWidget(
      {CellEditor changedCellEditor, CellEditorModel cellEditorModel})
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
        if (this.linkReference.referencedColumnNames.contains(v)) {
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
        this.linkReference != null &&
        this.linkReference.referencedColumnNames != null &&
        this.linkReference.referencedColumnNames.length > 0) {
      int columnIndex = -1;
      data.columnNames.asMap().forEach((i, c) {
        if (this.linkReference.referencedColumnNames[0] == c) columnIndex = i;
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
                  .withOpacity(globals.applicationStyle.controlsOpacity),
          borderRadius: BorderRadius.circular(
              globals.applicationStyle.cornerRadiusEditors),
          border:
              borderVisible ? Border.all(color: UIData.ui_kit_color_2) : null),
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return _items[index];
        },
      ),
    );
  }
}
