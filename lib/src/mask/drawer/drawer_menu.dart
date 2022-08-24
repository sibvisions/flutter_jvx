import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../model/command/api/logout_command.dart';
import '../../model/menu/menu_model.dart';
import '../menu/app_menu.dart';
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
      backgroundColor: Theme.of(context).backgroundColor.withOpacity(getConfigService().getOpacitySideMenu()),
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
    var profileImage = getConfigService().getUserInfo()?.profileImage;

    return DrawerHeader(
      margin: EdgeInsets.zero,
      decoration:
          BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(getConfigService().getOpacitySideMenu())),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.only(top: 10)),
                _buildHeaderText(
                  flex: 60,
                  text: getConfigService().getAppStyle()?['login.title'] ?? getConfigService().getAppName()!,
                  context: context,
                  fontWeight: FontWeight.bold,
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                _buildHeaderText(
                  flex: 20,
                  text: getConfigService().translateText("Logged in as") + ":",
                  context: context,
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 1)),
                _buildHeaderText(
                  flex: 35,
                  text: getConfigService().getUserInfo()?.displayName ?? " ",
                  context: context,
                  fontWeight: FontWeight.bold,
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 6)),
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
                    backgroundImage: profileImage != null ? MemoryImage(profileImage) : null,
                    child: profileImage == null
                        ? FaIcon(
                            FontAwesomeIcons.solidUser,
                            color: Colors.grey.shade400,
                            size: 60,
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
      onClick: AppMenu.menuItemPressed,
    );
  }

  List<Widget> _buildDrawerFooter(BuildContext context) {
    var footerEntries = [
      _buildFooterDivider(context),
      _buildFooterEntry(
        context: context,
        text: getConfigService().translateText("Settings"),
        leadingIcon: FontAwesomeIcons.gear,
        onTap: _settings,
      ),
    ];

    if (!getConfigService().isOffline()) {
      footerEntries.addAll([
        _buildFooterDivider(context),
        _buildFooterEntry(
          context: context,
          text: getConfigService().translateText("Change password"),
          leadingIcon: FontAwesomeIcons.key,
          onTap: _changePassword,
        ),
        _buildFooterDivider(context),
        _buildFooterEntry(
          context: context,
          text: getConfigService().translateText("Logout"),
          leadingIcon: FontAwesomeIcons.rightFromBracket,
          onTap: _logout,
        ),
      ]);
    }

    return footerEntries;
  }

  Divider _buildFooterDivider(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.onPrimary.withOpacity(getConfigService().getOpacitySideMenu()),
      height: 1,
    );
  }

  /// Build a text used in the header of the drawer.
  /// Flex value changes size according to all other header texts(Expanded).
  /// Text will size itself to fill available space(Fitted-Box).
  Widget _buildHeaderText({
    required int flex,
    required String text,
    required BuildContext context,
    FontWeight? fontWeight,
  }) {
    return Expanded(
      flex: flex,
      child: FittedBox(
        alignment: Alignment.topLeft,
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(getConfigService().getOpacitySideMenu()),
            fontWeight: fontWeight,
          ),
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
      tileColor: Theme.of(context).primaryColor.withOpacity(getConfigService().getOpacitySideMenu()),
      textColor: Theme.of(context).colorScheme.onPrimary.withOpacity(getConfigService().getOpacitySideMenu()),
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: FaIcon(
          leadingIcon,
          color: Theme.of(context).colorScheme.onPrimary.withOpacity(getConfigService().getOpacitySideMenu()),
        ),
      ),
      title: Text(
        text,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
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

  void _logout() {
    getUiService().setRouteContext(pContext: context);

    LogoutCommand logoutCommand = LogoutCommand(reason: "Drawer menu logout");
    getUiService().sendCommand(logoutCommand);
  }
}
