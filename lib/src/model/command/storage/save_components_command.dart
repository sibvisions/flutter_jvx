import 'storage_command.dart';
import '../../component/fl_component_model.dart';

class SaveComponentsCommand extends StorageCommand {

  List<FlComponentModel> componentsToSave;

  SaveComponentsCommand({
    required this.componentsToSave,
    required String reason
  }) : super(reason: reason);

}