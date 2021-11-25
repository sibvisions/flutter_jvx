import 'storage_command.dart';
import '../../component/fl_component_model.dart';

class SaveComponentsCommand extends StorageCommand {

  final List<FlComponentModel>? componentsToSave;
  final List<dynamic>? updatedComponent;

  SaveComponentsCommand({
    this.updatedComponent,
    this.componentsToSave,
    required String reason
  }) : super(reason: reason);

}