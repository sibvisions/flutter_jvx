import 'package:flutter/material.dart';

import '../../../../mixin/config_service_mixin.dart';
import '../../../../mixin/ui_service_mixin.dart';
import '../../../main.dart';
import '../../../util/image/image_loader.dart';
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

class _WebMenuState extends State<WebMenu> with ConfigServiceGetterMixin, UiServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  final TextStyle boldStyle = const TextStyle(
    fontWeight: FontWeight.bold,
  );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(seconds: 1), child: widget.showWebMenu ? _getNavWidget() : Container());
  }

  Widget _getNavWidget() {
    return Flexible(
      flex: 2,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      ImageLoader.getAssetPath(
                        FlutterJVx.package,
                        'assets/images/logo.png',
                      ),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildMenu(context)),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    MenuModel menuModel = getUiService().getMenuModel();
    return AppMenuListGrouped(
      menuModel: menuModel,
      onClick: AppMenu.menuItemPressed,
    );
  }
}
