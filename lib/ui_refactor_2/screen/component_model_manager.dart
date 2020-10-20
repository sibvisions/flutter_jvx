import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/container_component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/editor_component_model.dart';

class ComponentModelManager {
  Map<String, ComponentModel> _componentModels = <String, ComponentModel>{};

  ComponentModelManager();

  ComponentModel getComponentModelById(String componentId) {
    return this._componentModels[componentId];
  }

  ComponentModel addComponentModel(
      String componentId, ChangedComponent changedComponent,
      [bool overrideExisting = false]) {
    if (overrideExisting) {
      this._componentModels[componentId] =
          _getComponentModelByClassname(changedComponent);
      return this._componentModels[componentId];
    } else {
      if (this._componentModels[componentId] == null) {
        this._componentModels[componentId] =
            _getComponentModelByClassname(changedComponent);
      }
      return this._componentModels[componentId];
    }
  }

  ComponentModel removeComponentModel(ComponentModel componentModel) {
    return this._componentModels.remove(componentModel);
  }

  void removeAll() {
    this._componentModels = <String, ComponentModel>{};
  }

  ComponentModel _getComponentModelByClassname(
      ChangedComponent changedComponent) {
    ComponentModel componentModel;

    switch (changedComponent.className) {
      case 'Table':
        componentModel = EditorComponentModel(changedComponent);
        break;
      case 'Editor':
        componentModel = EditorComponentModel(changedComponent);
        break;
      case 'Panel':
        componentModel = ContainerComponentModel(
            changedComponent: changedComponent,
            componentId: changedComponent.id);
        break;
      case 'GroupPanel':
        componentModel = ContainerComponentModel(
            changedComponent: changedComponent,
            componentId: changedComponent.id);
        break;
      case 'ScrollPanel':
        componentModel = ContainerComponentModel(
            changedComponent: changedComponent,
            componentId: changedComponent.id);
        break;
      default:
        componentModel = ComponentModel(changedComponent);
        break;
    }

    return componentModel;
  }
}
