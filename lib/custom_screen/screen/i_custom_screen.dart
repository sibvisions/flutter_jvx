import 'package:jvx_mobile_v3/model/api/response/menu.dart';

abstract class ICustomScreen {
  shouldShowCustomScreen();

  onMenu(Menu menu);
}