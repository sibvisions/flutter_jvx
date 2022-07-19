import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../main.dart';
import '../../mixin/config_service_mixin.dart';
import '../../mixin/ui_service_mixin.dart';
import '../../model/command/api/logout_command.dart';
import '../../model/command/api/open_screen_command.dart';
import '../../model/menu/menu_model.dart';
import '../menu/list/app_menu_list_grouped.dart';
import '../setting/widgets/change_password.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({
    Key? key,
  }) : super(key: key);

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> with ConfigServiceGetterMixin, UiServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  final TextStyle boldStyle = const TextStyle(
    fontWeight: FontWeight.bold,
  );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).backgroundColor.withOpacity(opacitySideMenu),
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(child: _buildMenu(context)),
          ..._buildDrawerFooter(context),
        ],
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(opacitySideMenu)),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderText(flex: 7, text: getConfigService().getAppName(), context: context),
                const Padding(padding: EdgeInsets.all(4)),
                _buildHeaderText(
                    flex: 3, text: getConfigService().translateText("Logged in as") + ":", context: context),
                const Padding(padding: EdgeInsets.all(10)),
                _buildHeaderText(flex: 5, text: getConfigService().getUserInfo()?.displayName ?? "", context: context),
                const Expanded(flex: 2, child: Text(""))
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).backgroundColor,
                    backgroundImage: getConfigService().getUserInfo()?.profileImage?.image,
                    child: getConfigService().getUserInfo()?.profileImage == null
                        ? FaIcon(
                            FontAwesomeIcons.solidUser,
                            color: Theme.of(context).primaryColor,
                            size: 36,
                          )
                        : null,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    MenuModel menuModel = getUiService().getMenuModel();
    return AppMenuListGrouped(
      menuModel: menuModel,
      onClick: _menuItemPressed,
    );
  }

  List<Widget> _buildDrawerFooter(BuildContext context) {
    return [
      Divider(
        color: Theme.of(context).colorScheme.onPrimary.withOpacity(opacitySideMenu),
        height: 0.0,
        thickness: 0.5,
      ),
      _buildFooterEntry(
        context: context,
        text: getConfigService().translateText("Settings"),
        leadingIcon: FontAwesomeIcons.cogs,
        onTap: _settings,
      ),
      Divider(
        color: Theme.of(context).colorScheme.onPrimary.withOpacity(opacitySideMenu),
        height: 0.0,
        thickness: 0.5,
      ),
      _buildFooterEntry(
        context: context,
        text: getConfigService().translateText("Change password"),
        leadingIcon: FontAwesomeIcons.save,
        onTap: _changePassword,
      ),
      Divider(
        color: Theme.of(context).colorScheme.onPrimary.withOpacity(opacitySideMenu),
        height: 0.0,
        thickness: 0.5,
      ),
      _buildFooterEntry(
        context: context,
        text: getConfigService().translateText("Logout"),
        leadingIcon: FontAwesomeIcons.signOutAlt,
        onTap: _logout,
      ),
    ];
  }

  /// Build a text used in the header of the drawer.
  /// Flex value changes size according to all other header texts(Expanded).
  /// Text will size itself to fill available space(Fitted-Box).
  Widget _buildHeaderText({
    required int flex,
    required String text,
    required BuildContext context,
  }) {
    return Expanded(
      flex: flex,
      child: FittedBox(
        child: Text(
          text,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(opacitySideMenu), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Build an entry used in the footer of the drawer.
  Widget _buildFooterEntry({
    required BuildContext context,
    required String text,
    required IconData leadingIcon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      tileColor: Theme.of(context).primaryColor.withOpacity(opacitySideMenu),
      textColor: Theme.of(context).colorScheme.onPrimary.withOpacity(opacitySideMenu),
      onTap: onTap,
      leading: FaIcon(
        leadingIcon,
        color: Theme.of(context).colorScheme.onPrimary.withOpacity(opacitySideMenu),
      ),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  void _settings() {
    getUiService().setRouteContext(pContext: context);
    getUiService().routeToSettings();
  }

  void _changePassword() {
    getUiService().setRouteContext(pContext: context);
    getUiService().openDialog(
      pDialogWidget: ChangePassword(
        username: getConfigService().getUserInfo()?.userName,
      ),
      pIsDismissible: true,
    );
  }

  void _menuItemPressed({required String componentId}) {
    getUiService().setRouteContext(pContext: context);

    OpenScreenCommand command = OpenScreenCommand(componentId: componentId, reason: "Menu Item was pressed");
    getUiService().sendCommand(command);
  }

  void _logout() {
    getUiService().setRouteContext(pContext: context);

    LogoutCommand logoutCommand = LogoutCommand(reason: "Drawer menu logout");
    getUiService().sendCommand(logoutCommand);
  }
}
