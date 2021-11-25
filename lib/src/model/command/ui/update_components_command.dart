import 'package:flutter_client/src/model/command/ui/ui_command.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';

class UpdateComponentsCommand extends UiCommand {

  final List<FlComponentModel> affectedComponents;

  UpdateComponentsCommand({
    required this.affectedComponents,
    required String reason
  }) : super(reason: reason);

}