import 'package:jvx_mobile_v3/custom_screen/screen/i_custom_screen.dart';
import 'package:jvx_mobile_v3/model/api/response/menu.dart';

class CustomScreen implements ICustomScreen {
  @override
  shouldShowCustomScreen() {
    return false;
  }

  @override
  onMenu(Menu menu) {
    return null;
  }
}