import '../../../../../../model/command/base_command.dart';
import '../../../../../../model/component/fl_component_model.dart';
import '../../../../../isolate/isolate_message.dart';

class StorageIsolateUpdateComponentsMessage extends IsolateMessage<List<BaseCommand>> {
  final List<dynamic>? componentsToUpdate;
  final List<FlComponentModel>? newComponents;
  final String screenClassName;

  StorageIsolateUpdateComponentsMessage(
      {required this.componentsToUpdate, required this.newComponents, required this.screenClassName});
}
