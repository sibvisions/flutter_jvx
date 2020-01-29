import '../model/menu_item.dart';
import '../ui/screen/i_screen.dart';

abstract class ICustomScreen implements IScreen {
  IScreen getScreen(String componentId);

  List<MenuItem> onMenu(List<MenuItem> menu);
}