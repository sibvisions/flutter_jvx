import '../../../../../../model/component/fl_component_model.dart';
import '../../../../../isolate/isolate_message.dart';

class StorageIsolateGetScreenMessage extends IsolateMessage<List<FlComponentModel>> {
  final String screenClassName;

  StorageIsolateGetScreenMessage({required this.screenClassName});
}
