import 'dart:developer';

import 'package:flutter_jvx/src/models/api/custom/jvx_menu.dart';
import 'package:flutter_jvx/src/models/api/i_processor.dart';
import 'package:flutter_jvx/src/models/api/responses/response_menu.dart';
import 'package:flutter_jvx/src/models/events/menu/menu_added_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/on_menu_added_event.dart';

class MenuProcessor with OnMenuAddedEvent implements IProcessor {


  @override
  void processResponse(json) {
    ResponseMenu menu = ResponseMenu.fromJson(json);



    List<String> groups = [];

    for(ResponseMenuItem menuItem in menu.responseMenuItems){
      String groupName = menuItem.group;
      if(groups.any((element) => element != groupName) || groups.isEmpty){
        groups.add(groupName);
      }
    }

    List<JVxMenuGroup> jvxMenuGroups = groups.map((groupName) => JVxMenuGroup(
        name: groupName,
        items: _getMenuItemsByGroup(groupName, menu.responseMenuItems))
    ).toList();

    JVxMenu jVxMenu = JVxMenu(menuGroups: jvxMenuGroups);


    MenuAddedEvent event = MenuAddedEvent(
        reason: "Menu was parsed from Menu Server Response",
        origin: this,
        menu: jVxMenu
    );
    fireMenuAddedEvent(event);
  }


  List<JVxMenuItem> _getMenuItemsByGroup(String groupName, List<ResponseMenuItem> items){
    List<ResponseMenuItem> filteredItems = items.where((menuItem) => menuItem.group == groupName).toList();

    List<JVxMenuItem> jvxMenuItems = filteredItems.map((e) => JVxMenuItem(
        componentId: e.responseMenuItemAction.componentId,
        image: e.image,
        label: e.responseMenuItemAction.label)
    ).toList();

    return jvxMenuItems;
  }

}