import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../component/models/component_model.dart';

class EditorComponentModel extends ComponentModel {
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
