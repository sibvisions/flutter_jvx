import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/utils/convertion.dart';

class ChangedComponent {
  String id;
  String name;
  String className;
  String parent;
  int indexOf;
  ComponentProperties componentProperties;
  bool destroy;

  ChangedComponent({
    this.id,
    this.name,
    this.className,
    this.parent,
    this.indexOf,
    this.destroy
  });

  ChangedComponent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    className = json['className'];
    parent = json['parent'];
    indexOf = json['indexOf'];
    destroy = Convertion.convertToBool(json['~destroy']);

    componentProperties = new ComponentProperties(json);
  }
}