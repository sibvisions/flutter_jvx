import 'package:flutter/cupertino.dart';
import 'package:flutter_jvx/src/masks/menu/jvx_menu_group_widget.dart';
import 'package:flutter_jvx/src/masks/menu/jvx_menu_item_widget.dart';
import 'package:flutter_jvx/src/models/api/custom/jvx_menu.dart';

class JVxMenuWidget extends StatelessWidget{

  final List<JVxMenuGroup> menuGroups;


  const JVxMenuWidget({
    required this.menuGroups,
    Key? key
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: menuGroups.map((e) => JVxMenuGroupWidget(menuGroup: e)).toList(),
      )
    );
  }
}