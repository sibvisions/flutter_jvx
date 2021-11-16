import 'package:flutter_jvx/src/models/api/action/processor_action.dart';
import 'package:flutter_jvx/src/models/api/custom/jvx_menu.dart';

///
/// Create for newly added menu
///
class MenuAction extends ProcessorAction {
  final JVxMenu menu;

  MenuAction({required this.menu});
}