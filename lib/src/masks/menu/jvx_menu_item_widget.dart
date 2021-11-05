import 'package:flutter/cupertino.dart';
import 'package:flutter_jvx/src/models/api/custom/jvx_menu.dart';
import 'package:flutter_jvx/src/models/events/menu/menu_button_pressed_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/ui/on_menu_button_pressed_event.dart';

class JVxMenuItemWidget extends StatelessWidget with OnMenuButtonPressedEvent {
  final JVxMenuItem jVxMenuItem;

  JVxMenuItemWidget({
    Key? key,
    required this.jVxMenuItem
  }) : super(key: key);


  _onMenuItemClick(){
    MenuButtonPressedEvent event = MenuButtonPressedEvent(
        componentId: jVxMenuItem.componentId,
        origin: this,
        reason: "A menu item has been clicked on"
    );
    fireMenuButtonPressedEvent(event);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 182,
      child: (
        GestureDetector(
          onTap: _onMenuItemClick,
          child: Text(jVxMenuItem.label),
        )
      ),
    );
  }
}