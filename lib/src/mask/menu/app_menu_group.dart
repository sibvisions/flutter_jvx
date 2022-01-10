import 'package:flutter/material.dart';

import '../../model/menu/menu_group_model.dart';
import '../../service/ui/i_ui_service.dart';
import 'app_menu_item.dart';

class AppMenuGroup extends StatelessWidget {
  const AppMenuGroup({Key? key, required this.menuGroupModel, required this.uiService}) : super(key: key);

  final IUiService uiService;
  final MenuGroupModel menuGroupModel;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(menuGroupModel.name)],
      ),
      GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: menuGroupModel.items.length,
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150, crossAxisSpacing: 5, mainAxisExtent: 70, mainAxisSpacing: 5),
        itemBuilder: (context, index) => AppMenuItem(menuItemModel: menuGroupModel.items[index], uiService: uiService),
      )
    ]);
  }
}
