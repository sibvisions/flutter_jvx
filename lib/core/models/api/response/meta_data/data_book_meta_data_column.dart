import '../../component/component_properties.dart';
import '../../editor/cell_editor.dart';

class DataBookMetaDataColumn extends ComponentProperties {
  static final String _cellEditorIdentifier = "cellEditor";
  String name;
  String label;
  CellEditor cellEditor;
  int dataTypeIdentifier;
  bool readOnly;
  bool nullable;

  DataBookMetaDataColumn.fromJson(Map<String, dynamic> json) : super(json) {
    name = this.getProperty<String>(ComponentProperty.NAME);
    label = this.getProperty<String>(ComponentProperty.LABEL);
    dataTypeIdentifier =
        this.getProperty<int>(ComponentProperty.DATA_TYPE_IDENTIFIER);
    readOnly = this.getProperty<bool>(ComponentProperty.READONLY);
    nullable = this.getProperty<bool>(ComponentProperty.NULLABLE);

    if (json[_cellEditorIdentifier] != null)
      cellEditor = CellEditor.fromJson(json[_cellEditorIdentifier]);
  }
}
