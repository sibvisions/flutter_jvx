import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';

class ChangedComponent extends ComponentProperties {
  static final String _cellEditorIdentifier = "cellEditor";
  String id;
  String name;
  String className;
  CellEditor cellEditor;
  bool destroy;
  bool remove;

  get layoutName {
    List<String> parameter = this.getProperty<String>(ComponentProperty.LAYOUT)?.split(",");
    if (parameter!= null && parameter.length>0) {
      return parameter[0];
    } 

    return null;
  }

  ChangedComponent.fromJson(Map<String, dynamic> json) : super(json) {
    id = this.getProperty<String>(ComponentProperty.ID);
    name = this.getProperty<String>(ComponentProperty.NAME);
    className = this.getProperty<String>(ComponentProperty.CLASS_NAME);
    destroy = this.getProperty<bool>(ComponentProperty.$DESTROY, false);
    remove =  this.getProperty<bool>(ComponentProperty.$REMOVE, false);

    if (json[_cellEditorIdentifier] != null) cellEditor = CellEditor.fromJson(json[_cellEditorIdentifier]);
  }
}