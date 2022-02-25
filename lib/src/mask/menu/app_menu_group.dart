import 'dart:ui';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            menuGroupModel.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 25,
            ),
          ),
        ),
        GridView.extent(
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          maxCrossAxisExtent: 150,
          padding: const EdgeInsets.all(5),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          semanticChildCount: menuGroupModel.items.length,
          children: menuGroupModel.items.map((e) => AppMenuItem(menuItemModel: e, uiService: uiService)).toList(),
        ),
      ],
    );
  }
}
// menuGroupModel.items.map((e) => AppMenuItem(menuItemModel: e, uiService: uiService)).toList(),