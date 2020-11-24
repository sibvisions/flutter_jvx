<<<<<<< HEAD
import 'dart:collection';

import 'package:jvx_flutterclient/core/ui/editor/celleditor/cell_editor_model.dart';

import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../component/models/component_model.dart';
import '../screen/so_component_data.dart';

class EditorComponentModel extends ComponentModel {
  Queue<SoComponentData> _toUpdateData = Queue<SoComponentData>();

  CellEditorModel cellEditorModel;
=======
import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../component/component_model.dart';

class EditorComponentModel extends ComponentModel {
>>>>>>> dev
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

<<<<<<< HEAD
  // Queue<SoComponentData> get toUpdateData => _toUpdateData;
  // set toUpdateData(Queue<SoComponentData> toUpdateData) =>
  //     _toUpdateData = toUpdateData;

  @override
  get preferredSize {
    if (super.preferredSize != null) return super.preferredSize;
    if (cellEditorModel != null) return cellEditorModel.preferredSize;
    return null;
  }

  @override
  get minimumSize {
    if (super.minimumSize != null) return super.minimumSize;
    if (cellEditorModel != null) return cellEditorModel.minimumSize;

    return null;
  }

  @override
  get maximumSize {
    if (super.maximumSize != null) return super.maximumSize;
    if (cellEditorModel != null) return cellEditorModel.maximumSize;

    return null;
  }

=======
>>>>>>> dev
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
