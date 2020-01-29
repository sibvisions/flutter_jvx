import 'package:jvx_mobile_v3/custom_screen/custom_screen_manager/i_custom_screen_manager.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/ui/screen/component_creator.dart';
import 'package:jvx_mobile_v3/ui/screen/i_screen.dart';

class CustomScreenManager extends ICustomScreenManager {
  @override
  getScreen(String componentId) {
    return IScreen(ComponentCreator());
  }

  @override
  List<MenuItem> onMenu(List<MenuItem> menu) {
    return menu;
  }

}