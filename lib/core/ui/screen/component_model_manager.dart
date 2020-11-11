import '../../models/api/component/changed_component.dart';
import '../component/component_model.dart';
import '../component/label_component_model.dart';
import '../component/popup_menu/popup_button_component_model.dart';
import '../component/popup_menu/popup_component_model.dart';
import '../container/container_component_model.dart';
import '../editor/editor_component_model.dart';

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
      case 'TabsetPanel':
        componentModel = ContainerComponentModel(
            changedComponent: changedComponent,
            componentId: changedComponent.id);
        break;
      case 'SplitPanel':
        componentModel = ContainerComponentModel(
          changedComponent: changedComponent,
          componentId: changedComponent.id,
        );
        break;
      case 'PopupMenu':
        componentModel = PopupComponentModel(changedComponent);
        break;
      case 'PopupMenuButton':
        componentModel = PopupButtonComponentModel(changedComponent);
        break;
      case 'Label':
        componentModel = LabelComponentModel(changedComponent);
        break;
      default:
        componentModel = ComponentModel(changedComponent);
        break;
    }

    return componentModel;
  }
}
