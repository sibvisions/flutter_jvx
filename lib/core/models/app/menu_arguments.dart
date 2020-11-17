import '../api/response.dart';
import '../api/response/menu_item.dart';

class MenuArguments {
  final List<MenuItem> menuItems;
  final bool listMenuItemsInDrawer;
  final Response welcomeScreen;

  MenuArguments(this.menuItems, this.listMenuItemsInDrawer,
      [this.welcomeScreen]);
}
