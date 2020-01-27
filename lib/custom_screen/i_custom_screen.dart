import 'package:jvx_mobile_v3/model/api/response/menu.dart';
import 'package:jvx_mobile_v3/ui/screen/i_screen.dart';

abstract class ICustomScreen implements IScreen {
  shouldShowCustomScreen();

  onMenu(Menu menu);
}