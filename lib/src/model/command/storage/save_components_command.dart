import 'package:flutter_client/src/model/command/storage/storage_command.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';

class SaveComponentsCommand extends StorageCommand {

  List<FlComponentModel> componentsToSave;

  SaveComponentsCommand({
    required this.componentsToSave,
    required String reason
  }) : super(reason: reason);

}