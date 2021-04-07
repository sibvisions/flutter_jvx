import '../../../../services/remote/cubit/api_cubit.dart';
import '../../../api/response_objects/menu/menu_item.dart';
import '../../../api/response_objects/menu/menu_item.dart';

class MenuPageArguments {
  final List<MenuItem> menuItems;
  final bool listMenuItemsInDrawer;
  final ApiResponse? response;

  MenuPageArguments(
      {required this.menuItems,
      required this.listMenuItemsInDrawer,
      this.response});
}
