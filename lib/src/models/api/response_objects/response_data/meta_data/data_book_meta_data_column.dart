import 'package:flutterclient/src/models/api/response_objects/response_data/component/component_properties.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/editor/cell_editor.dart';

class DataBookMetaDataColumn extends ComponentProperties {
  static final String _cellEditorIdentifier = "cellEditor";
  String? name;
  String? label;
  CellEditor? cellEditor;
  int? dataTypeIdentifier;
  bool? readOnly;
  bool? nullable;

  DataBookMetaDataColumn.fromJson(Map<String, dynamic> json) : super(json) {
    name = this.getProperty<String>(ComponentProperty.NAME, name ?? '');
    label = this.getProperty<String>(ComponentProperty.LABEL, label ?? '');
    dataTypeIdentifier = this.getProperty<int>(
        ComponentProperty.DATA_TYPE_IDENTIFIER, dataTypeIdentifier ?? -1);
    readOnly =
        this.getProperty<bool>(ComponentProperty.READONLY, readOnly ?? false);
    nullable =
        this.getProperty<bool>(ComponentProperty.NULLABLE, nullable ?? true);

    if (json[_cellEditorIdentifier] != null)
      cellEditor = CellEditor.fromJson(json[_cellEditorIdentifier]);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'label': label,
        'dataTypeIdentifier': dataTypeIdentifier,
        'readOnly': readOnly,
        'nullable': nullable,
        'cellEditor': cellEditor?.toJson(),
      };
}
