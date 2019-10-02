import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/utils/convertion.dart';

class ChangedComponent {
  String id;
  String name;
  String className;
  String parent;
  int indexOf;
  ComponentProperties componentProperties;
  CellEditor cellEditor;
  bool destroy;
  bool remove;
  String layout;
  String layoutData;

  ChangedComponent({
    this.id,
    this.name,
    this.className,
    this.parent,
    this.indexOf,
    this.destroy,
    this.cellEditor,
  });

  ChangedComponent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    className = json['className'];
    parent = json['parent'];
    indexOf = json['indexOf'];
    layout = json['layout'];
    layoutData = json['layoutData'];
    destroy = Convertion.convertToBool(json['~destroy']);
    remove = Convertion.convertToBool(json['~remove']);
    
    if (json['cellEditor'] != null) cellEditor = CellEditor.fromJson(json['cellEditor']);
    componentProperties = new ComponentProperties(json);
  }
}