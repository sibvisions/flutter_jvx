import '../../../custom/app_manager.dart';
import '../layout/layout_data.dart';
import 'fl_component_model.dart';

class ComponentSubscription<T extends FlComponentModel> {
  /// The object that subscribed, used for deletion
  final Object subbedObj;

  /// Component id, will receive all changes to this component
  final String compId;

  /// Component callback to notify a component it is affected.
  final Function()? affectedCallback;

  /// Component callback to receive new model data.
  final Function(T pNewModel)? modelCallback;

  /// Component callback to receive new layout data
  final Function(LayoutData pLayout)? layoutCallback;

  /// Component callback to notify of saving.
  final BaseCommand? Function()? saveCallback;

  ComponentSubscription({
    required this.compId,
    required this.subbedObj,
    this.affectedCallback,
    this.modelCallback,
    this.layoutCallback,
    this.saveCallback,
  });
}
