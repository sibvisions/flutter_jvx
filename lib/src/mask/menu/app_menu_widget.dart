import 'package:flutter/material.dart';

import '../../model/menu/menu_group_model.dart';
import '../../service/ui/i_ui_service.dart';
import 'app_menu_group.dart';

class AppMenuWidget extends StatelessWidget {
  const AppMenuWidget({
    Key? key,
    this.menuGroups = const [],
    required this.uiService,
  }) : super(key: key);

  final IUiService uiService;
  final List<MenuGroupModel> menuGroups;

  @override
  Widget build(BuildContext context) {
    return (Column(
      mainAxisSize: MainAxisSize.min,
      children: menuGroups
          .map((e) => AppMenuGroup(
                menuGroupModel: e,
                uiService: uiService,
              ))
          .toList(),
    ));
  }
}
