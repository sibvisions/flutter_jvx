import 'package:flutterclient/src/ui/component/component_widget.dart';
import 'package:flutterclient/src/ui/component/model/component_model.dart';

abstract class IComponentCreator {
  IComponentCreator();

  ComponentWidget createComponent(ComponentModel componentModel);
}
