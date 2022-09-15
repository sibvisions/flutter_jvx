import 'package:flutter/material.dart';

import '../../../../mixin/config_service_mixin.dart';
import '../../../../mixin/ui_service_mixin.dart';
import '../../../util/parse_util.dart';
import '../../model/menu/menu_model.dart';
import '../menu/app_menu.dart';
import '../menu/list/app_menu_list_grouped.dart';

class WebMenu extends StatefulWidget {
  final bool showWebMenu;

  final void Function() onSettingsPressed;
  final void Function() onChangePasswordPressed;
  final void Function() onLogoutPressed;

  const WebMenu({
    Key? key,
    this.showWebMenu = true,
    required this.onSettingsPressed,
    required this.onChangePasswordPressed,
    required this.onLogoutPressed,
  }) : super(key: key);

  @override
  State<WebMenu> createState() => _WebMenuState();
}

class _WebMenuState extends State<WebMenu>
    with ConfigServiceGetterMixin, UiServiceGetterMixin, SingleTickerProviderStateMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  final TextStyle boldStyle = const TextStyle(
    fontWeight: FontWeight.bold,
  );

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      value: widget.showWebMenu ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 246),
      vsync: this,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      widthFactor: animationController.value,
      child: RepaintBoundary(
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 4,
          child: _buildMenu(context),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(WebMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showWebMenu != oldWidget.showWebMenu) {
      animationController.fling(velocity: widget.showWebMenu ? 1.0 : -1.0);
    }
  }

  Widget _buildMenu(BuildContext context) {
    Color? color = ParseUtil.parseHexColor(getConfigService().getAppStyle()?["web.sidemenu.color"]);
    Color? groupColor = ParseUtil.parseHexColor(getConfigService().getAppStyle()?["web.sidemenu.groupColor"]);
    Color? textColor = ParseUtil.parseHexColor(getConfigService().getAppStyle()?["web.sidemenu.textColor"]);
    Color? selectionColor = ParseUtil.parseHexColor(getConfigService().getAppStyle()?["web.sidemenu.selectionColor"]);

    MenuModel menuModel = getUiService().getMenuModel();
    return ListTileTheme.merge(
      tileColor: color,
      textColor: textColor,
      iconColor: textColor,
      selectedColor: selectionColor,
      selectedTileColor: color,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      horizontalTitleGap: 0,
      child: Theme(
        data: Theme.of(context).copyWith(
          bottomAppBarColor: groupColor,
        ),
        child: IconTheme.merge(
          data: const IconThemeData(size: 16),
          child: DividerTheme(
            data: DividerTheme.of(context).copyWith(
              color: color,
            ),
            child: AppMenuListGrouped(
              menuModel: menuModel,
              onClick: AppMenu.menuItemPressed,
            ),
          ),
        ),
      ),
    );
  }
}
