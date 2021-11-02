import 'package:flutter_jvx/src/models/api/custom/jvx_menu.dart';
import 'package:flutter_jvx/src/models/api/responses/response_menu.dart';

abstract class IMenuService {


  JVxMenu? getMenu();
}