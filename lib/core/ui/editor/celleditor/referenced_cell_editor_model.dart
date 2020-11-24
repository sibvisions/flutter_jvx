import 'package:flutter/material.dart';

import '../../../models/api/editor/cell_editor.dart';
import '../../../models/api/editor/column_view.dart';
import '../../../models/api/editor/link_reference.dart';
import '../../../models/api/response/data/data_book.dart';
import '../../editor/celleditor/cell_editor_model.dart';
import '../../screen/so_component_data.dart';

class ReferencedCellEditorModel extends CellEditorModel {
  SoComponentData referencedData;
  LinkReference linkReference;
  ColumnView columnView;
  String referenceDataProvider;

  ReferencedCellEditorModel(CellEditor currentCellEditor)
      : super(currentCellEditor) {
    linkReference = currentCellEditor.linkReference;
    columnView = currentCellEditor.columnView;
    if (linkReference?.dataProvider == null)
      linkReference?.dataProvider = linkReference?.referencedDataBook;
    if (dataProvider == null) dataProvider = linkReference?.dataProvider;
  }

  List<String> getItems() {
    List<String> items = <String>[];

    if (this.referencedData?.data != null ?? false) {
      DataBook data = this.referencedData.data;
      List<int> visibleColumnsIndex = this.getVisibleColumnIndex(data);

      if (data != null && data.records.isNotEmpty) {
        data.records.asMap().forEach((j, record) {
          record.asMap().forEach((i, c) {
            if (visibleColumnsIndex.contains(i)) {
              items.add(c.toString());
            }
          });
        });
      }
    }
    return items;
  }

  List<int> getVisibleColumnIndex(DataBook data) {
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
}
