import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/utils/convertion.dart';

class ChangedComponent {
  String id;
  String name;
  String className;
  String parent;
  int indexOf;

  CellEditor cellEditor;
  bool destroy;
  bool remove;

  ComponentProperties componentProperties;

  get hasLayout  => (layoutName?.isNotEmpty ?? true);
  get layoutName => getLayoutName(layoutRaw);
  get layoutRaw => componentProperties.getProperty<String>("layout");
  get layoutData => componentProperties.getProperty<String>("layoutData");

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
    destroy = Convertion.convertToBool(json['~destroy']);
    remove = Convertion.convertToBool(json['~remove']);
    
    if (json['cellEditor'] != null) cellEditor = CellEditor.fromJson(json['cellEditor']);
    componentProperties = new ComponentProperties(json);
  }

  static String getLayoutName(String layoutString) {
    List<String> parameter = layoutString?.split(",");
    if (parameter!= null && parameter.length>0) {
      return parameter[0];
    } 

    return null;
  }
}