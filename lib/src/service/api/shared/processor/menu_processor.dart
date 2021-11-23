import 'package:flutter_client/src/model/api/response/menu_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/storage/save_menu_command.dart';
import 'package:flutter_client/src/model/menu/menu_group_model.dart';
import 'package:flutter_client/src/model/menu/menu_item_model.dart';
import 'package:flutter_client/src/model/menu/menu_model.dart';
import 'package:flutter_client/src/service/api/shared/i_processor.dart';

class MenuProcessor implements IProcessor {

  @override
  List<BaseCommand> processResponse(json) {
    List<BaseCommand> commands = [];
    MenuResponse response = MenuResponse.fromJson(json);


    List<MenuGroupModel> groups = _isolateGroups(response);
    for(MenuGroupModel group in groups){
      group.items.addAll(_getItemsByGroup(group.name, response.responseMenuItems));
    }
    MenuModel menuModel = MenuModel(menuGroups: groups);


    SaveMenuCommand menuCommand = SaveMenuCommand(
        reason: "Menu was added from Server response",
        menu: menuModel
    );
    commands.add(menuCommand);

    return commands;
  }

  List<MenuGroupModel> _isolateGroups(MenuResponse menu) {
    List<MenuGroupModel> groups = [];
    for(MenuEntryResponse entry in menu.responseMenuItems){
      if(!groups.any((element) => element.name == entry.group)){
        groups.add(MenuGroupModel(name: entry.group, items: []));
      }
    }
    return groups;
  }

  List<MenuItemModel> _getItemsByGroup(String groupName, List<MenuEntryResponse> entries) {
    List<MenuItemModel> menuItems = [];
    for(MenuEntryResponse responseMenuEntry in entries){
      if(responseMenuEntry.group == groupName){
        MenuItemModel menuItem = MenuItemModel(componentId: responseMenuEntry.componentId, label: responseMenuEntry.text);
        menuItems.add(menuItem);
      }
    }
    return menuItems;
  }

}