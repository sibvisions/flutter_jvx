import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../model/menu/menu_model.dart';
import '../menu/app_menu.dart';
import '../menu/list/app_menu_list_grouped.dart';
import '../state/app_style.dart';

class DrawerMenu extends StatefulWidget {
  final void Function() onSettingsPressed;
  final void Function() onChangePasswordPressed;
  final void Function() onLogoutPressed;

  const DrawerMenu({
    Key? key,
    required this.onSettingsPressed,
    required this.onChangePasswordPressed,
    required this.onLogoutPressed,
  }) : super(key: key);

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  final TextStyle boldStyle = const TextStyle(
    fontWeight: FontWeight.bold,
  );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  Widget build(BuildContext context) {
    bool isNormalSize = MediaQuery.of(context).size.height > 650;
    List<Widget> footerEntries = _buildDrawerFooter(context, isNormalSize);

    return Opacity(
      opacity: IConfigService().getOpacitySideMenu(),
      child: Drawer(
        backgroundColor: Theme.of(context).backgroundColor,
        child: Column(
          children: [
            _buildDrawerHeader(context, isNormalSize),
            Expanded(child: _buildMenu(context, isNormalSize)),
            if (isNormalSize) ...footerEntries,
            if (!isNormalSize)
              SizedBox(
                height: 55,
                child: Row(children: footerEntries),
              ),
          ],
        ),
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildDrawerHeader(BuildContext context, bool isNormalSize) {
    var profileImage = IConfigService().getUserInfo()?.profileImage;

    List<Widget> headerItems = [
      _buildHeaderText(
        flex: 5,
        text: AppStyle.of(context)!.applicationStyle!['login.title'] ?? IConfigService().getAppName()!,
        context: context,
        constraints: const BoxConstraints(maxWidth: 150),
        fontWeight: FontWeight.bold,
      ),
      const Spacer(flex: 1),
      Expanded(
        flex: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderText(
              flex: 1,
              text: "${FlutterJVx.translate("Logged in as")}:",
              context: context,
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 1)),
            _buildHeaderText(
              flex: 2,
              text: IConfigService().getUserInfo()?.displayName ?? " ",
              context: context,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    ];

    return SizedBox(
      height: isNormalSize ? 170 : 100,
      child: DrawerHeader(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: isNormalSize
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: headerItems,
                    )
                  : Row(
                      children: headerItems,
                    ),
            ),
            if (isNormalSize)
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
      ),
    );
  }

  Widget _buildMenu(BuildContext context, bool isNormalSize) {
    MenuModel menuModel = IUiService().getMenuModel();
    return ListTileTheme.merge(
      iconColor: Theme.of(context).colorScheme.primary,
      style: ListTileStyle.drawer,
      dense: !isNormalSize,
      child: IconTheme(
        data: IconTheme.of(context).copyWith(
          size: 32,
        ),
        child: AppMenuListGrouped(
          menuModel: menuModel,
          onClick: AppMenu.menuItemPressed,
        ),
      ),
    );
  }

  List<Widget> _buildDrawerFooter(BuildContext context, bool isNormalSize) {
    var footerEntries = [
      _buildFooterDivider(context),
      _buildFooterEntry(
        context: context,
        text: FlutterJVx.translate("Settings"),
        leadingIcon: FontAwesomeIcons.gear,
        onTap: widget.onSettingsPressed,
        isNormalSize: isNormalSize,
      ),
    ];

    if (!IConfigService().isOffline()) {
      footerEntries.addAll([
        _buildFooterDivider(context),
        _buildFooterEntry(
          context: context,
          text: FlutterJVx.translate("Change password"),
          leadingIcon: FontAwesomeIcons.key,
          onTap: widget.onChangePasswordPressed,
          isNormalSize: isNormalSize,
        ),
        _buildFooterDivider(context),
        _buildFooterEntry(
          context: context,
          text: FlutterJVx.translate("Logout"),
          leadingIcon: FontAwesomeIcons.rightFromBracket,
          onTap: widget.onLogoutPressed,
          isNormalSize: isNormalSize,
        ),
      ]);
    }

    return footerEntries;
  }

  Divider _buildFooterDivider(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.onPrimary,
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
    BoxConstraints? constraints,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        constraints: constraints,
        child: FittedBox(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: constraints,
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: fontWeight,
              ),
            ),
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
    bool isNormalSize = true,
  }) {
    if (isNormalSize) {
      return ListTile(
        tileColor: Theme.of(context).colorScheme.primary,
        textColor: Theme.of(context).colorScheme.onPrimary,
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: FaIcon(
            leadingIcon,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        title: isNormalSize
            ? Text(
                text,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        onTap: onTap,
      );
    } else {
      return Flexible(
        child: Material(
          color: Theme.of(context).colorScheme.primary,
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: FaIcon(
                leadingIcon,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      );
    }
  }
}
