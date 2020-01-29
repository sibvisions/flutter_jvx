import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/ui/screen/i_screen.dart';

abstract class ICustomScreenManager {
  IScreen getScreen(String componentId);

  List<MenuItem> onMenu(List<MenuItem> menu);
}