import 'package:flutter_client/src/mask/menu/app_menu_group.dart';
import 'package:flutter_client/src/model/menu/menu_group_model.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';
import 'package:flutter/material.dart';

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
    return(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: menuGroups.map((e) => AppMenuGroup(menuGroupModel: e, uiService: uiService,)).toList(),
        )
    );
  }
}
