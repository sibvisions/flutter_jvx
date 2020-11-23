import '../../models/api/component/changed_component.dart';
import 'component_model.dart';

typedef ComponentValueChangedCallback = void Function(
    String componentId, dynamic value);

class EditableComponentModel extends ComponentModel {
  ComponentValueChangedCallback onComponentValueChanged;

  EditableComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);
}
