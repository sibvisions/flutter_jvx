import 'package:flutter/cupertino.dart';
import 'package:flutter_jvx/src/masks/menu/jvx_menu_item_widget.dart';
import 'package:flutter_jvx/src/models/api/custom/jvx_menu.dart';

class JVxMenuGroupWidget extends StatelessWidget {

  final JVxMenuGroup menuGroup;

  const JVxMenuGroupWidget({
    required this.menuGroup,
    Key? key
  }) : super(key: key);

  // menuGroup.items.map((e) => JVxMenuItemWidget(label: e.label)).toList(),
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(menuGroup.name)],
        ),
        GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: menuGroup.items.length,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150,
            crossAxisSpacing: 1,
            mainAxisExtent: 70
          ),
          itemBuilder: (context, index) => JVxMenuItemWidget(jVxMenuItem: menuGroup.items[index]),
        )
      ]
    );
  }
}