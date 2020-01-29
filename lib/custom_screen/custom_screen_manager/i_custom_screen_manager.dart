import 'package:jvx_mobile_v3/model/menu_item.dart';

abstract class ICustomScreenManager {
  getScreen(String componentId);

  List<MenuItem> onMenu(List<MenuItem> menu);
}