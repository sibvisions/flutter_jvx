import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/properties/properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_referenced_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/widgets/custom_dropdown_button.dart' as custom;
import 'package:jvx_mobile_v3/ui/widgets/lazy_linked_cell_editor.dart';

class JVxLinkedCellEditor extends JVxReferencedCellEditor {
  List<DropdownMenuItem> _items = <DropdownMenuItem>[];
  String initialData;
  int pageIndex = 0;
  int pageSize = 100;

  JVxLinkedCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context);

  void valueChanged(dynamic value) {
    this.value = value;
    this.onValueChanged(value);
  }

  List<int> getVisibleColumnIndex(JVxData data) {
    List<int> visibleColumnsIndex = <int>[];
    if (data != null && data.records.isNotEmpty) {
      data.columnNames.asMap().forEach((i, v) {
        if (this.columnView != null && this.columnView.columnNames != null) {
          if (this.columnView.columnNames.contains(v)) {
            visibleColumnsIndex.add(i);
          }
        } else if (this.linkReference != null &&
            this.linkReference.referencedColumnNames != null &&
            this.linkReference.referencedColumnNames.contains(v)) {
          visibleColumnsIndex.add(i);
        }
      });
    }

    return visibleColumnsIndex;
  }

  List<DropdownMenuItem> getItems(JVxData data) {
    List<DropdownMenuItem> items = <DropdownMenuItem>[];
    List<int> visibleColumnsIndex = this.getVisibleColumnIndex(data);

    if (data != null && data.records.isNotEmpty) {
      data.records.asMap().forEach((j, record) {
        if (j >= pageIndex * pageSize && j < (pageIndex + 1) * pageSize) {
          record.asMap().forEach((i, c) {
            if (visibleColumnsIndex.contains(i)) {
              items.add(getItem(c.toString(), c.toString()));
            }
          });
        }
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
                Properties.utf8convert(text),
              ),
            ],
          ),
        ));
  }

  @override
  void onServerDataChanged() {}

  void onSave(dynamic value) {}

  void onFilter(dynamic value) {}

  void onScrollToEnd() {
    JVxData _data = data.getData(context, null, pageSize);
    if (_data != null && _data.records != null)
        data.getData(
            context, null, this.pageSize + _data.records.length);
  }

  void onCancel() {}

  @override
  Widget getWidget() {
    String h = this.value;
    String v = this.value;
    JVxData data = this
        .data
        .getData(this.context, null, (this.pageIndex + 1) * this.pageSize);
    this._items = getItems(data);

    if (!this._items.contains((i) => (i as DropdownMenuItem).value == v))
      v = null;

    if (data.records.length < 20) {
      return custom.CustomDropdownButton(
        hint: Text(Properties.utf8convert(h == null ? "" : h)),
        value: v,
        items: this._items,
        onChanged: valueChanged,
        isExpanded: true,
      );
    } else {
      return custom.CustomDropdownButton(
        hint: Text(Properties.utf8convert(h == null ? "" : h)),
        value: v,
        items: this._items,
        onChanged: valueChanged,
        isExpanded: true,
        onOpen: () {
          showDialog(
              context: context,
              builder: (context) => LazyLinkedCellEditor(
                  data: data,
                  context: context,
                  visibleColumnIndex: this.getVisibleColumnIndex(data),
                  fetchMoreYOffset: MediaQuery.of(context).size.height * 4,
                  onSave: onSave,
                  onFilter: onFilter,
                  allowNull: true,
                  onScrollToEnd: onScrollToEnd,
                  onCancel: onCancel));
        },
      );
    }
  }
}
