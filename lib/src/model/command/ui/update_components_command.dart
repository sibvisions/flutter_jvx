import 'ui_command.dart';
import '../../component/fl_component_model.dart';

class UpdateComponentsCommand extends UiCommand {

  final List<FlComponentModel> affectedComponents;

  UpdateComponentsCommand({
    required this.affectedComponents,
    required String reason
  }) : super(reason: reason);

}