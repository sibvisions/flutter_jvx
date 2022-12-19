import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../../util/jvx_colors.dart';
import '../../model/menu/menu_model.dart';
import '../menu/list/grouped_list_menu.dart';
import '../menu/menu.dart';

class DrawerMenu extends StatefulWidget {
  final void Function() onSettingsPressed;
  final void Function() onChangePasswordPressed;
  final void Function() onLogoutPressed;

  const DrawerMenu({
    super.key,
    required this.onSettingsPressed,
    required this.onChangePasswordPressed,
    required this.onLogoutPressed,
  });

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

    return Opacity(
      opacity: IConfigService().getOpacitySideMenu(),
      child: Drawer(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).colorScheme.primary
            : JVxColors.darken(Theme.of(context).cardColor, 0.05),
        child: SafeArea(
          top: false,
          left: false,
          right: false,
          child: ValueListenableBuilder<bool>(
            valueListenable: IConfigService().getOfflineNotifier(),
            builder: (context, isOffline, child) {
              return Column(
                children: [
                  _buildDrawerHeader(context, isNormalSize),
                  Expanded(child: _buildMenu(context, isNormalSize)),
                  if (isNormalSize) ..._buildDrawerFooter(context, isOffline, isNormalSize),
                  if (!isNormalSize)
                    SizedBox(
                      height: 55,
                      child: Row(children: _buildDrawerFooter(context, isOffline, isNormalSize)),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildDrawerHeader(BuildContext context, bool isNormalSize) {
    var profileImage = IConfigService().getUserInfo()?.profileImage;

    List<Widget> headerItems;

    if (isNormalSize) {
      headerItems = [
        _buildHeaderText(
          flex: 5,
          text: AppStyle.of(context)!.applicationStyle!['login.title'] ?? IConfigService().getAppName()!,
          context: context,
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
    } else {
      headerItems = [
        Flexible(
          child: _buildHeaderText(
            text: IConfigService().getUserInfo()?.displayName ?? " ",
            context: context,
            constraints: const BoxConstraints(maxWidth: 120),
            fontWeight: FontWeight.bold,
          ),
        ),
      ];
    }

    return SizedBox(
      height: isNormalSize ? 170 : 100,
      child: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).primaryTextTheme,
          iconTheme: Theme.of(context).primaryIconTheme,
        ),
        child: DrawerHeader(
          margin: EdgeInsets.zero,
          padding: isNormalSize ? const EdgeInsets.all(12.0) : const EdgeInsets.all(7.0).copyWith(left: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: isNormalSize
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: headerItems,
                      )
                    : Row(
                        children: headerItems,
                      ),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
              AspectRatio(
                aspectRatio: 1.0,
                child: CircleAvatar(
                  radius: 100,
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
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context, bool isNormalSize) {
    return ValueListenableBuilder<MenuModel>(
      valueListenable: IUiService().getMenuNotifier(),
      builder: (context, _, child) {
        return ColoredBox(
          color: Theme.of(context).backgroundColor,
          child: ListTileTheme.merge(
            iconColor: Theme.of(context).colorScheme.primary,
            style: ListTileStyle.drawer,
            dense: !isNormalSize,
            child: IconTheme(
              data: IconTheme.of(context).copyWith(
                size: 32,
              ),
              child: GroupedListMenu(
                menuModel: IUiService().getMenuModel(),
                onClick: Menu.menuItemPressed,
                useAlternativeLabel: true,
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDrawerFooter(BuildContext context, bool isOffline, bool isNormalSize) {
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

    if (!isOffline) {
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
        _buildFooterDivider(context),
      ]);
    }

    return footerEntries;
  }

  Divider _buildFooterDivider(BuildContext context) {
    return Divider(
      //Specifically requested color mix
      color: JVxColors.lighten(Theme.of(context).colorScheme.onPrimary, 0.4),
      height: 1,
    );
  }

  /// Build a text used in the header of the drawer.
  /// Flex value changes size according to all other header texts(Expanded).
  /// Text will size itself to fill available space(Fitted-Box).
  Widget _buildHeaderText({
    int? flex,
    required String text,
    required BuildContext context,
    FontWeight? fontWeight,
    BoxConstraints? constraints,
  }) {
    Widget child = Container(
      constraints: constraints,
      width: double.infinity,
      child: FittedBox(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: fontWeight,
          ),
        ),
      ),
    );

    if (flex != null) {
      child = Expanded(
        flex: flex,
        child: child,
      );
    }

    return child;
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
        textColor: Theme.of(context).colorScheme.onPrimary,
        iconColor: Theme.of(context).colorScheme.onPrimary,
        leading: Builder(
          builder: (context) => CircleAvatar(
            backgroundColor: Colors.transparent,
            child: FaIcon(
              leadingIcon,
              color: IconTheme.of(context).color,
            ),
          ),
        ),
        title: isNormalSize ? Text(text, overflow: TextOverflow.ellipsis) : null,
        onTap: onTap,
      );
    } else {
      return Flexible(
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: FaIcon(
              leadingIcon,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      );
    }
  }
}
