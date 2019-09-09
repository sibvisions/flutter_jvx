import 'package:jvx_mobile_v3/model/data/meta_data/jvx_meta_data_cell_editor.dart';

class JVxMetaDataColumn {
  String name;
  String label;
  JVxMetaDataCellEditor jVxCellEditor;
  int dataTypeIdentifier;
  bool readOnly;
  bool nullable;

  JVxMetaDataColumn({this.name, this.label, this.jVxCellEditor, this.dataTypeIdentifier, this.readOnly, this.nullable});

  JVxMetaDataColumn.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      label = json['label'],
      jVxCellEditor = JVxMetaDataCellEditor.fromJson(json['cellEditor']),
      dataTypeIdentifier = json['dataTypeIdentifier'],
      readOnly = json['readOnly'],
      nullable = json['nullable'];
}