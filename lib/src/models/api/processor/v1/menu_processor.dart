import 'dart:developer';

import 'package:flutter_jvx/src/models/api/custom/jvx_menu.dart';
import 'package:flutter_jvx/src/models/api/i_processor.dart';
import 'package:flutter_jvx/src/models/api/responses/response_menu.dart';
import 'package:flutter_jvx/src/models/events/menu/menu_added_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/meta/on_menu_added_event.dart';

class MenuProcessor with OnMenuAddedEvent implements IProcessor {


  @override
  void processResponse(json) {
    ResponseMenu menu = ResponseMenu.fromJson(json);

    List<JVxMenuGroup> groups = _isolateGroups(menu);
    for(JVxMenuGroup group in groups){
      group.items.addAll(_getItemsByGroup(group.name, menu.responseMenuItems));
    }


    JVxMenu jVxMenu = JVxMenu(menuGroups: groups);



    MenuAddedEvent event = MenuAddedEvent(
        reason: "Menu was parsed from Menu Server Response",
        origin: this,
        menu: jVxMenu
    );
    fireMenuAddedEvent(event);
  }

  List<JVxMenuGroup> _isolateGroups(ResponseMenu menu) {
    List<JVxMenuGroup> groups = [];
    for(ResponseMenuEntry entry in menu.responseMenuItems){
      if(!groups.any((element) => element.name == entry.group)){
        groups.add(JVxMenuGroup(name: entry.group, items: []));
      }
    }
    return groups;
  }

  List<JVxMenuItem> _getItemsByGroup(String groupName, List<ResponseMenuEntry> entries) {
    List<JVxMenuItem> menuItems = [];
    for(ResponseMenuEntry responseMenuEntry in entries){
      if(responseMenuEntry.group == groupName){
        JVxMenuItem menuItem = JVxMenuItem(componentId: responseMenuEntry.componentId, label: responseMenuEntry.text);
        menuItems.add(menuItem);
      }
    }
    return menuItems;
  }


}