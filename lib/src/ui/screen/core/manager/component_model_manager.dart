import 'package:flutterclient/src/ui/component/model/icon_component_model.dart';
import 'package:flutterclient/src/ui/editor/editor_component_model.dart';

import '../../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../component/co_action_component_widget.dart';
import '../../../component/co_action_component_widget.dart';
import '../../../component/model/button_component_model.dart';
import '../../../component/model/component_model.dart';
import '../../../component/model/editable_component_model.dart';
import '../../../component/model/label_component_model.dart';
import '../../../container/models/container_component_model.dart';

class ComponentModelManager {
  Map<String, ComponentModel> _componentModels = <String, ComponentModel>{};

  ComponentModelManager();

  ComponentModel? getComponentModelById(String componentId) {
    return this._componentModels[componentId];
  }

  ComponentModel? addComponentModel(ChangedComponent changedComponent,
      {bool overrideExisting = false,
      ActionCallback? onAction,
      ComponentValueChangedCallback? onComponentValueChanged}) {
    if (overrideExisting) {
      this._componentModels[changedComponent.id!] =
          _getComponentModelByClassname(changedComponent,
              onAction: onAction,
              onComponentValueChanged: onComponentValueChanged);
      return this._componentModels[changedComponent.id];
    } else {
      if (this._componentModels[changedComponent.id] == null) {
        this._componentModels[changedComponent.id!] =
            _getComponentModelByClassname(changedComponent,
                onAction: onAction,
                onComponentValueChanged: onComponentValueChanged);
      }
      return this._componentModels[changedComponent.id];
    }
  }

  ComponentModel? removeComponentModel(ComponentModel componentModel) {
    return this._componentModels.remove(componentModel);
  }

  void removeAll() {
    this._componentModels = <String, ComponentModel>{};
  }

  ComponentModel _getComponentModelByClassname(
      ChangedComponent changedComponent,
      {ActionCallback? onAction,
      ComponentValueChangedCallback? onComponentValueChanged}) {
    ComponentModel? componentModel;

    switch (changedComponent.className) {
      // case 'Table':
      //   componentModel = TableComponentModel(changedComponent);
      //   break;
      case 'Editor':
        componentModel =
            EditorComponentModel(changedComponent: changedComponent);
        break;
      case 'Panel':
        componentModel = ContainerComponentModel(
          changedComponent: changedComponent,
        );
        break;
      // case 'GroupPanel':
      //   componentModel = GroupPanelComponentModel(
      //       changedComponent: changedComponent,
      //       componentId: changedComponent.id);
      //   break;
      // case 'ScrollPanel':
      //   componentModel = ContainerComponentModel(
      //       changedComponent: changedComponent,
      //       componentId: changedComponent.id);
      //   break;
      // case 'TabsetPanel':
      //   componentModel = TabsetPanelComponentModel(
      //       changedComponent: changedComponent,
      //       componentId: changedComponent.id);
      //   break;
      // case 'SplitPanel':
      //   componentModel = SplitPanelComponentModel(
      //     changedComponent: changedComponent,
      //     componentId: changedComponent.id,
      //   );
      //   break;
      // case 'PopupMenu':
      //   componentModel = PopupMenuComponentModel(changedComponent);
      //   break;
      // case 'PopupMenuButton':
      //   componentModel = PopupMenuButtonComponentModel(changedComponent);
      //   break;
      // case 'MenuItem':
      //   componentModel = MenuItemComponentModel(changedComponent);
      //   break;
      case 'Label':
        componentModel =
            LabelComponentModel(changedComponent: changedComponent);
        break;
      case 'Button':
        componentModel = ButtonComponentModel(
            changedComponent: changedComponent, onAction: onAction!);
        break;
      // case 'CheckBox':
      //   componentModel = SelectableComponentModel(changedComponent);
      //   break;
      // case 'RadioButton':
      //   componentModel = SelectableComponentModel(changedComponent);
      //   break;
      case 'Icon':
        componentModel = IconComponentModel(changedComponent: changedComponent);
        break;
      // case 'TextField':
      //   componentModel = TextFieldComponentModel(changedComponent);
      //   break;
      // case 'TextArea':
      //   componentModel = TextAreaComponentModel(changedComponent);
      //   break;
      // case 'PasswordField':
      //   componentModel = TextFieldComponentModel(changedComponent);
      //   break;
      // case 'ToggleButton':
      //   componentModel = ToggleButtonComponentModel(changedComponent);
      //   break;
      // case 'Map':
      //   componentModel = MapComponentModel(changedComponent);
      //   break;
      // default:
      //   componentModel = ComponentModel(changedComponent);
      //   break;
    }

    if (componentModel != null) {
      return componentModel;
    } else {
      throw Exception('Couldn\'t create component model.');
    }
  }
}
