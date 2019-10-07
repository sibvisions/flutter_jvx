import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_label.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_referenced_cell_editor.dart';

class JVxLinkedCellEditor extends JVxReferencedCellEditor {
  List<DropdownMenuItem> _items = <DropdownMenuItem>[];
  String initialData;

  JVxLinkedCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context);

  void valueChanged(dynamic value) {
    this.value = value;
    this.onValueChanged(value);
  }

  List<DropdownMenuItem> getItems(JVxData data) {
    List<DropdownMenuItem> items = <DropdownMenuItem>[];
    List<int> visibleColumnsIndex = <int>[];

    if (data != null && data.records.isNotEmpty) {
      data.columnNames.asMap().forEach((i, v) {
        if (this.linkReference.referencedColumnNames.contains(v)) {
          visibleColumnsIndex.add(i);
        }
      });

      data.records.forEach((record) {
        record.asMap().forEach((i, c) {
          if (visibleColumnsIndex.contains(i)) {
            items.add(getItem(c.toString(), c.toString()));
          }
        });
      });
    }

    if (items.length == 0) items.add(getItem('loading', 'Loading...'));

    return items;
  }

  DropdownMenuItem getItem(dynamic value, String text) {
    return DropdownMenuItem(
        value: value,
        child: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                JVxLabel.utf8convert(text),
              ),
            ],
          ),
        ));
  }

  @override
  void setInitialData(JVxData data) {
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

    initialData = data.records[0][0];

    this.setData(data);
  }

  @override
  void setData(JVxData data) {
    /*if (data?.records?.length==1) {
      this.value = data.records[0][0];
    }*/

    this._items = getItems(data);
  }

  @override
  Widget getWidget() {
    return DropdownButton(
      hint: Text(JVxLabel.utf8convert(initialData)),
      value: this.value,
      items: this._items,
      onChanged: valueChanged,
      isExpanded: true,
    );
  }
}
