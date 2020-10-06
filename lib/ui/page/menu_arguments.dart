import '../../jvx_flutterclient.dart';
import '../../model/api/response/response.dart';

class MenuArguments {
  final List<MenuItem> menuItems;
  final bool listMenuItemsInDrawer;
  final Response welcomeResponse;

  MenuArguments(this.menuItems, this.listMenuItemsInDrawer,
      [this.welcomeResponse]);
}
