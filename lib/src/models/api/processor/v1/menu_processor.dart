
import 'package:flutter_jvx/src/models/api/action/menu_action.dart';
import 'package:flutter_jvx/src/models/api/action/processor_action.dart';
import 'package:flutter_jvx/src/models/api/custom/jvx_menu.dart';
import 'package:flutter_jvx/src/models/api/i_processor.dart';
import 'package:flutter_jvx/src/models/api/responses/response_menu.dart';

class MenuProcessor implements IProcessor {


  @override
  List<ProcessorAction> processResponse(json) {
    List<ProcessorAction> actions = [];
    ResponseMenu menu = ResponseMenu.fromJson(json);

    List<JVxMenuGroup> groups = _isolateGroups(menu);
    for(JVxMenuGroup group in groups){
      group.items.addAll(_getItemsByGroup(group.name, menu.responseMenuItems));
    }


    JVxMenu jVxMenu = JVxMenu(menuGroups: groups);
    MenuAction menuAction = MenuAction(menu: jVxMenu);
    actions.add(menuAction);

    return actions;
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