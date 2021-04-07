import 'package:flutterclient/src/models/api/response_objects/response_data/data/data_book.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/editor/cell_editor.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/editor/column_view.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/editor/link_reference.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/models/cell_editor_model.dart';
import 'package:flutterclient/src/ui/screen/core/so_component_data.dart';

class ReferencedCellEditorModel extends CellEditorModel {
  SoComponentData? referencedData;
  LinkReference? linkReference;
  ColumnView? columnView;
  String? referenceDataProvider;

  ReferencedCellEditorModel({required CellEditor cellEditor})
      : super(cellEditor: cellEditor) {
    linkReference = cellEditor.linkReference;
    columnView = cellEditor.columnView;
    if (linkReference?.dataProvider == null)
      linkReference?.dataProvider = linkReference?.referencedDataBook;
    if (dataProvider == null) dataProvider = linkReference?.dataProvider;
  }

  List<String> getItems() {
    List<String> items = <String>[];

    if (referencedData?.data != null) {
      DataBook data = referencedData!.data!;
      List<int> visibleColumnsIndex = getVisibleColumnIndex(data);

      if (data.records.isNotEmpty) {
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
    if (data.records.isNotEmpty) {
      data.columnNames.asMap().forEach((i, v) {
        if (columnView != null && columnView!.columnNames.isNotEmpty) {
          if (columnView!.columnNames.contains(v)) {
            visibleColumnsIndex.add(i);
          }
        } else if (linkReference != null &&
            linkReference!.referencedColumnNames.contains(v)) {
          visibleColumnsIndex.add(i);
        }
      });
    }

    return visibleColumnsIndex;
  }
}
