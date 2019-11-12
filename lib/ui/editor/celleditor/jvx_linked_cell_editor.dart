import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/properties/properties.dart';
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
        if (this.columnView!=null && this.columnView.columnNames!=null && this.columnView.columnNames.contains(v)) {
          visibleColumnsIndex.add(i);
        } else if (this.linkReference != null && this.linkReference.referencedColumnNames!=null && this.linkReference.referencedColumnNames.contains(v)) {
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

    if (items.length == 0) 
      items.add(getItem('loading', 'Loading...'));

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
                Properties.utf8convert(text),
              ),
            ],
          ),
        ));
  }

  @override
  void onServerDataChanged() {

  }

  @override
  Widget getWidget() {
    String h = this.value;
    String v = this.value;
    this._items = getItems(this.data.getData(this.context, null));

    if (!this._items.contains((i) => (i as DropdownMenuItem).value==v))
      v = null;

    return DropdownButton(
      hint: Text(Properties.utf8convert(h==null?"":h)),
      value: v,
      items: this._items,
      onChanged: valueChanged,
      isExpanded: true,
    );
  }
}
