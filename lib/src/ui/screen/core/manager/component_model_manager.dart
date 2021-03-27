import 'package:flutterclient/src/ui/component/model/icon_component_model.dart';
import 'package:flutterclient/src/ui/component/model/selectable_component_model.dart';
import 'package:flutterclient/src/ui/component/model/table_component_model.dart';
import 'package:flutterclient/src/ui/component/model/text_area_component_model.dart';
import 'package:flutterclient/src/ui/component/model/text_field_component_model.dart';
import 'package:flutterclient/src/ui/component/model/toggle_button_component_model.dart';
import 'package:flutterclient/src/ui/component/popup_menu/models/menu_item_component_model.dart';
import 'package:flutterclient/src/ui/component/popup_menu/models/popup_menu_button_component_model.dart';
import 'package:flutterclient/src/ui/component/popup_menu/models/popup_menu_component_model.dart';
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
      required ActionCallback onAction,
      required ComponentValueChangedCallback onComponentValueChanged}) {
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
      {required ActionCallback onAction,
      required ComponentValueChangedCallback onComponentValueChanged}) {
    ComponentModel? componentModel;

    switch (changedComponent.className) {
      case 'Table':
        componentModel =
            TableComponentModel(changedComponent: changedComponent);
        break;
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
      case 'PopupMenu':
        componentModel =
            PopupMenuComponentModel(changedComponent: changedComponent);
        break;
      case 'PopupMenuButton':
        componentModel = PopupMenuButtonComponentModel(
            changedComponent: changedComponent, onAction: onAction);
        break;
      case 'MenuItem':
        componentModel =
            MenuItemComponentModel(changedComponent: changedComponent);
        break;
      case 'Label':
        componentModel =
            LabelComponentModel(changedComponent: changedComponent);
        break;
      case 'Button':
        componentModel = ButtonComponentModel(
            changedComponent: changedComponent, onAction: onAction);
        break;
      case 'CheckBox':
        componentModel = SelectableComponentModel(
            changedComponent: changedComponent,
            onComponentValueChanged: onComponentValueChanged);
        break;
      case 'RadioButton':
        componentModel = SelectableComponentModel(
            changedComponent: changedComponent,
            onComponentValueChanged: onComponentValueChanged);
        break;
      case 'Icon':
        componentModel = IconComponentModel(changedComponent: changedComponent);
        break;
      case 'TextField':
        componentModel = TextFieldComponentModel(
            changedComponent: changedComponent,
            onComponentValueChanged: onComponentValueChanged);
        break;
      case 'TextArea':
        componentModel = TextAreaComponentModel(
            changedComponent: changedComponent,
            onComponentValueChanged: onComponentValueChanged);
        break;
      case 'PasswordField':
        componentModel = TextFieldComponentModel(
            changedComponent: changedComponent,
            onComponentValueChanged: onComponentValueChanged);
        break;
      case 'ToggleButton':
        componentModel = ToggleButtonComponentModel(
            changedComponent: changedComponent, onAction: onAction);
        break;
      // case 'Map':
      //   componentModel = MapComponentModel(changedComponent);
      //   break;
      // default:
      //   componentModel = ComponentModel(changedComponent: changedComponent);
      //   break;
    }

    if (componentModel != null) {
      return componentModel;
    } else {
      throw Exception('Couldn\'t create component model.');
    }
  }
}
