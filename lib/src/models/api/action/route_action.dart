import 'package:flutter_jvx/src/models/api/action/processor_action.dart';
import 'package:flutter_jvx/src/routing/routing_options.dart';


class RouteAction extends ProcessorAction {

  ///Only the highest priority route, in a response, will be executed
  final int priority;
  ///Where to Route
  final RoutingOptions routingOptions;
  ///WorkScreenName in case the route goes to a WorkScreen
  final String? workScreenName;

  RouteAction({
    required this.priority,
    required this.routingOptions,
    this.workScreenName
  });
}