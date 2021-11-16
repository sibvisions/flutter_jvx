import 'package:flutter_jvx/src/models/api/action/processor_action.dart';
import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';

///
/// Created for every new OR changed Component model in screen.generic responses
///
class ComponentAction extends ProcessorAction {

  ///Parsed componentModel
  final UiComponentModel componentModel;

  ComponentAction({required this.componentModel});
}