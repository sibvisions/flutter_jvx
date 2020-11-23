import '../../../models/api/component/changed_component.dart';
import '../../../models/api/component/component_properties.dart';
import 'component_model.dart';

class IconComponentModel extends ComponentModel {
  String text;
  bool selected = false;
  bool eventAction = false;
  String image;

  @override
  int verticalAlignment = 1;
  @override
  int horizontalAlignment = 1;

  IconComponentModel(ChangedComponent changedComponent)
      : super(changedComponent) {
    eventAction = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
    selected = changedComponent.getProperty<bool>(
        ComponentProperty.SELECTED, selected);
    image =
        changedComponent.getProperty<String>(ComponentProperty.IMAGE, image);
  }
}
