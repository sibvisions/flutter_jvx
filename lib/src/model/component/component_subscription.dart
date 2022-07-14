import '../../service/ui/i_ui_service.dart';

class ComponentSubscription {
  /// The object that subscribed, used for deletion
  final Object subbedObj;

  /// Component id, will receive all changes to this component
  final String compId;

  /// Callback that will be executed
  final ComponentCallback callback;

  ComponentSubscription({
    required this.callback,
    required this.compId,
    required this.subbedObj,
  });
}
