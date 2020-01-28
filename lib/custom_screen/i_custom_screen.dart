import '../model/menu_item.dart';
import '../ui/screen/i_screen.dart';

abstract class ICustomScreen implements IScreen {
  shouldShowCustomScreen();

  onMenu(List<MenuItem> menu);
}