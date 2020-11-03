import 'dart:collection';

import 'package:jvx_flutterclient/ui_refactor_2/screen/so_component_data.dart';

import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../component/component_model.dart';
import 'co_editor_widget.dart';

class EditorComponentModel extends ComponentModel {
  Queue<SoComponentData> _toUpdateData = Queue<SoComponentData>();

  String dataProvider;
  String dataRow;
  String columnName;

  // For Table in LinkedCellEditor

  bool _withChangedComponent = true;
  bool tableHeaderVisible;
  bool editable;
  bool autoResize;
  List<String> columnNames;
  List<String> columnLabels;
  Function onRowTapped;
  int indexInTable;
  dynamic value;

  bool get withChangedComponent => _withChangedComponent;

  // Queue<SoComponentData> get toUpdateData => _toUpdateData;
  // set toUpdateData(Queue<SoComponentData> toUpdateData) =>
  //     _toUpdateData = toUpdateData;

  EditorComponentModel(ChangedComponent changedComponent)
      : super(changedComponent) {
    if (changedComponent != null) {
      if (dataProvider == null)
        dataProvider = changedComponent.getProperty<String>(
            ComponentProperty.DATA_BOOK, dataProvider);

      dataRow =
          changedComponent.getProperty<String>(ComponentProperty.DATA_ROW);

      if (dataProvider == null) dataProvider = dataRow;
    }
  }

  EditorComponentModel.withoutChangedComponent(
      bool tableHeaderVisible,
      bool editable,
      bool autoResize,
      List<String> columnNames,
      Function onRowTapped,
      int indexInTable,
      dynamic value,
      String columnName,
      List<String> columnLabels)
      : super(null) {
    this._withChangedComponent = false;
    this.tableHeaderVisible = tableHeaderVisible;
    this.editable = editable;
    this.autoResize = autoResize;
    this.columnNames = columnNames;
    this.onRowTapped = onRowTapped;
    this.indexInTable = indexInTable;
    this.value = value;
    this.columnName = columnName;
    this.columnLabels = columnLabels;
  }
}
