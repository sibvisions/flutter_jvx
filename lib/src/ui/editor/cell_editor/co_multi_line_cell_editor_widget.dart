import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/data/data_book.dart';

import 'co_referenced_cell_editor_widget.dart';
import 'models/multi_line_cell_editor_model.dart';
import 'models/referenced_cell_editor_model.dart';

class CoMultiLineCellEditorWidget extends CoReferencedCellEditorWidget {
  final ReferencedCellEditorModel cellEditorModel;
  CoMultiLineCellEditorWidget({required this.cellEditorModel})
      : super(cellEditorModel: cellEditorModel);

  @override
  CoReferencedCellEditorWidgetState<CoMultiLineCellEditorWidget>
      createState() => CoMultiLineCellEditorWidgetState();
}

class CoMultiLineCellEditorWidgetState
    extends CoReferencedCellEditorWidgetState<CoMultiLineCellEditorWidget> {
  void valueChanged(dynamic value) {
    widget.cellEditorModel.cellEditorValue = value;
    this.onValueChanged!(context, value);
  }

  List<ListTile> getItems(DataBook data) {
    List<ListTile> items = <ListTile>[];
    List<int> visibleColumnsIndex = <int>[];

    if (data.records.isNotEmpty) {
      data.columnNames.asMap().forEach((i, v) {
        if (widget.cellEditorModel.linkReference!.referencedColumnNames
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
        (widget.cellEditorModel as MultiLineCellEditorModel).selectedValue =
            val;
        valueChanged(val);
      },
      selected:
          (widget.cellEditorModel as MultiLineCellEditorModel).selectedValue ==
                  val
              ? true
              : false,
      title: Text(text),
    );
  }

  void setInitialData(DataBook data) {
    if (data.selectedRow != null &&
        data.selectedRow! >= 0 &&
        data.selectedRow! < data.records.length &&
        data.columnNames.length > 0 &&
        widget.cellEditorModel.linkReference != null &&
        widget.cellEditorModel.linkReference!.referencedColumnNames.length >
            0) {
      int columnIndex = -1;
      data.columnNames.asMap().forEach((i, c) {
        if (widget.cellEditorModel.linkReference!.referencedColumnNames[0] == c)
          columnIndex = i;
      });
      if (columnIndex >= 0) {
        widget.cellEditorModel.cellEditorValue =
            data.records[data.selectedRow!][columnIndex];
      }
    }

    this.setData(data);
  }

  void setData(DataBook data) {
    (widget.cellEditorModel as MultiLineCellEditorModel).items = getItems(data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: widget.cellEditorModel.backgroundColor != null
              ? widget.cellEditorModel.backgroundColor
              : Colors.white.withOpacity(widget.cellEditorModel.appState
                      .applicationStyle?.controlsOpacity ??
                  1),
          borderRadius: BorderRadius.circular(widget.cellEditorModel.appState
                  .applicationStyle?.cornerRadiusEditors ??
              5),
          border: widget.cellEditorModel.borderVisible
              ? Border.all(color: Theme.of(context).primaryColor)
              : null),
      child: ListView.builder(
        itemCount:
            (widget.cellEditorModel as MultiLineCellEditorModel).items.length,
        itemBuilder: (context, index) {
          return (widget.cellEditorModel as MultiLineCellEditorModel)
              .items[index];
        },
      ),
    );
  }
}
