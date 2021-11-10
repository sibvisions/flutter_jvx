import 'package:flutter_jvx/src/models/api/custom/jvx_menu.dart';
import 'package:flutter_jvx/src/models/events/base_event.dart';

class MenuAddedEvent extends BaseEvent {

  final JVxMenu menu;

  MenuAddedEvent({
    required String reason,
    required Object origin,
    required this.menu
  }): super(origin: origin, reason: reason);

}