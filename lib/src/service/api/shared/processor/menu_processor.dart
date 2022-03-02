import '../../../../model/command/ui/route_command.dart';
import '../../../../routing/app_routing_type.dart';

import '../../../../model/api/response/menu_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/storage/save_menu_command.dart';
import '../../../../model/menu/menu_group_model.dart';
import '../../../../model/menu/menu_item_model.dart';
import '../../../../model/menu/menu_model.dart';
import '../i_processor.dart';

class MenuProcessor implements IProcessor {
  @override
  List<BaseCommand> processResponse(json) {
    List<BaseCommand> commands = [];
    MenuResponse response = MenuResponse.fromJson(json);

    List<MenuGroupModel> groups = _isolateGroups(response);
    for (MenuGroupModel group in groups) {
      group.items.addAll(_getItemsByGroup(group.name, response.responseMenuItems));
    }
    MenuModel menuModel = MenuModel(menuGroups: groups);

    SaveMenuCommand menuCommand = SaveMenuCommand(reason: "Menu was added from Server response", menu: menuModel);

    RouteCommand routeCommand = RouteCommand(routeType: AppRoutingType.menu, reason: "A Menu was received.");

    commands.add(menuCommand);
    commands.add(routeCommand);

    return commands;
  }

  List<MenuGroupModel> _isolateGroups(MenuResponse menu) {
    List<MenuGroupModel> groups = [];
    for (MenuEntryResponse entry in menu.responseMenuItems) {
      if (!groups.any((element) => element.name == entry.group)) {
        groups.add(MenuGroupModel(name: entry.group, items: []));
      }
    }
    return groups;
  }

  List<MenuItemModel> _getItemsByGroup(String groupName, List<MenuEntryResponse> entries) {
    List<MenuItemModel> menuItems = [];
    for (MenuEntryResponse responseMenuEntry in entries) {
      if (responseMenuEntry.group == groupName) {
        MenuItemModel menuItem = MenuItemModel(
            componentId: responseMenuEntry.componentId, label: responseMenuEntry.text, image: responseMenuEntry.image);
        menuItems.add(menuItem);
      }
    }
    return menuItems;
  }
}
