import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';

import '../../jvx_screen.dart';

class JVxLinkedCellEditor extends JVxCellEditor {
  List<DropdownMenuItem> _items = List<DropdownMenuItem>();
  JVxLinkedCellEditor(ComponentProperties properties, BuildContext context) : super(properties, context);
  
  void valueChanged(dynamic value) {
    getIt.get<JVxScreen>().setValues(dataProvider, linkReference.columnNames, [value]);
  }

  List<DropdownMenuItem> getItems(JVxData data) {
      List<DropdownMenuItem> items = <DropdownMenuItem>[];
      List<int> visibleComunsIndex = <int>[];

      if (data != null && data.records.isNotEmpty) {
        data.columnNames.asMap().forEach((i, v) {
          if (this.linkReference.referencedColumnNames.contains(v)) {
            visibleComunsIndex.add(i);
          }
        });

        data.records.forEach((record) {
          record.asMap().forEach((i, c) {
            if (visibleComunsIndex.contains(i)) {
              items.add(getItem(c.toString(), c.toString()));
            }
          });
        });
      }
      else
        items.add(getItem('loading', 'Loading...'));

      return items;
  }

  DropdownMenuItem getItem(dynamic value, String text) {
    return DropdownMenuItem(
      value: value,
      child: Text(text)
    );
  }

  @override
  void setData(JVxData data) {
    this._items = getItems(data);
  }

  @override
  Widget getWidget() {
    // ToDo: Implement getWidget
    return DropdownButton(
      items: this._items,
      onChanged: valueChanged
    );
  }
}