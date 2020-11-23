import '../../../models/api/component/changed_component.dart';
import '../../../models/api/component/component_properties.dart';
import 'editable_component_model.dart';

class TextComponentModel extends EditableComponentModel {
  bool eventAction = false;
  bool border;
  int horizontalAlignment;
  int columns;
  bool valueChanged = false;

  TextComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);

    eventAction = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
    border = changedComponent.getProperty<bool>(ComponentProperty.BORDER, true);
    columns =
        changedComponent.getProperty<int>(ComponentProperty.COLUMNS, columns);
  }

  void onTextFieldValueChanged(dynamic newValue) {
    if (text != newValue) {
      text = newValue;
      this.valueChanged = true;
    }
  }

  void onTextFieldEndEditing() {
    if (this.valueChanged) {
      onComponentValueChanged(this.rawComponentId, text);
      this.valueChanged = false;
    }
  }
}
