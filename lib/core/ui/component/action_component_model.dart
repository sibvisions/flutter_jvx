import '../../models/api/component/changed_component.dart';
import '../../models/api/so_action.dart';
import 'component_model.dart';

class ActionComponentModel extends ComponentModel {
  SoAction action;

  ActionComponentModel(ChangedComponent changedComponent)
      : super(changedComponent) {
    action = SoAction(componentId: this.name, label: this.text);
  }
}
