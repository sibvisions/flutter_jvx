/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../flutter_ui.dart';
import '../../model/menu/menu_model.dart';
import '../../service/api/i_api_service.dart';
import '../../service/config/config_controller.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/jvx_colors.dart';
import '../apps/app_overview_page.dart';
import '../menu/list/list_menu.dart';
import '../menu/menu.dart';
import '../state/app_style.dart';

class DrawerMenu extends StatefulWidget {
  final void Function() onSettingsPressed;
  final void Function() onChangePasswordPressed;
  final void Function() onLogoutPressed;
  final void Function() onAppChange;

  const DrawerMenu({
    super.key,
    required this.onSettingsPressed,
    required this.onChangePasswordPressed,
    required this.onLogoutPressed,
    required this.onAppChange,
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
      opacity: double.parse(AppStyle.of(context).applicationStyle['opacity.sidemenu'] ?? "1"),
      child: Drawer(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).colorScheme.primary
            : JVxColors.darken(Theme.of(context).colorScheme.surface, 0.05),
        child: SafeArea(
          top: false,
          left: false,
          right: false,
          child: ValueListenableBuilder<bool>(
            valueListenable: ConfigController().offline,
            builder: (context, isOffline, child) {
              return Column(
                children: [
                  _buildDrawerHeader(context, isNormalSize),
                  Expanded(child: _buildMenu(context, isNormalSize)),
                  if (isNormalSize) ..._buildDrawerFooter(context, isOffline, isNormalSize),
                  if (!isNormalSize)
                    SizedBox(
                      height: 56,
                      child: Row(
                        children: _buildDrawerFooter(context, isOffline, isNormalSize),
                      ),
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
    var profileImage = ConfigController().userInfo.value?.profileImage;

    List<Widget> headerItems;

    if (isNormalSize) {
      headerItems = [
        _buildHeaderText(
          flex: 5,
          text: AppStyle.of(context).applicationStyle['login.title'] ?? ConfigController().appName.value ?? "",
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
                text: "${FlutterUI.translate("Logged in as")}:",
                context: context,
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 1)),
              _buildHeaderText(
                flex: 2,
                text: ConfigController().userInfo.value?.displayName ?? " ",
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
            text: ConfigController().userInfo.value?.displayName ?? " ",
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
                  backgroundColor: Theme.of(context).colorScheme.background,
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
          color: Theme.of(context).colorScheme.background,
          child: ListTileTheme.merge(
            iconColor: Theme.of(context).colorScheme.primary,
            style: ListTileStyle.drawer,
            dense: !isNormalSize,
            child: IconTheme(
              data: IconTheme.of(context).copyWith(
                size: 32,
              ),
              child: ListMenu(
                key: const PageStorageKey('DrawerMenu'),
                menuModel: IUiService().getMenuModel(),
                onClick: Menu.menuItemPressed,
                useAlternativeLabel: true,
                grouped: true,
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
        text: FlutterUI.translate("Settings"),
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
          text: FlutterUI.translate("Change password"),
          leadingIcon: FontAwesomeIcons.key,
          onTap: widget.onChangePasswordPressed,
          isNormalSize: isNormalSize,
        ),
        _buildFooterDivider(context),
      ]);
      if (isNormalSize) {
        List<Widget> children;
        if (AppOverviewPage.showAppsButton()) {
          children = [
            Expanded(
              flex: 10,
              child: _buildLogoutEntry(context, isNormalSize),
            ),
            _buildFooterVerticalDivider(context),
            Expanded(flex: 7, child: _buildAppsEntry(context, isNormalSize)),
          ];
        } else {
          children = [Expanded(child: _buildLogoutEntry(context, isNormalSize))];
        }

        footerEntries.addAll([
          SizedBox(
            height: kIsWeb ? 48 : 56,
            child: Row(
              children: children,
            ),
          ),
        ]);
      } else {
        List<Widget> children;
        if (AppOverviewPage.showAppsButton()) {
          children = [
            _buildAppsEntry(context, isNormalSize),
            _buildFooterDivider(context),
            _buildLogoutEntry(context, isNormalSize),
          ];
        } else {
          children = [_buildLogoutEntry(context, isNormalSize)];
        }

        footerEntries.addAll(children);
      }
      footerEntries.add(_buildFooterDivider(context));
    }

    return footerEntries;
  }

  Widget _buildAppsEntry(BuildContext context, bool isNormalSize) {
    return _buildFooterEntry(
      context: context,
      text: FlutterUI.translate("Apps"),
      leadingIcon: AppOverviewPage.appsIcon,
      onTap: widget.onAppChange,
      isNormalSize: isNormalSize,
    );
  }

  Widget _buildLogoutEntry(BuildContext context, bool isNormalSize) {
    String text;
    IconData icon;

    if (IApiService().getRepository().cancelledSessionExpired.value) {
      text = "Restart";
      icon = FontAwesomeIcons.arrowsRotate;
    } else {
      text = "Logout";
      icon = FontAwesomeIcons.rightFromBracket;
    }

    return _buildFooterEntry(
      context: context,
      text: FlutterUI.translate(text),
      leadingIcon: icon,
      onTap: widget.onLogoutPressed,
      isNormalSize: isNormalSize,
    );
  }

  Widget _buildFooterDivider(BuildContext context) {
    return Divider(
      // Specifically requested color mix
      color: JVxColors.dividerColor(Theme.of(context)),
      height: 1,
    );
  }

  Widget _buildFooterVerticalDivider(BuildContext context) {
    return VerticalDivider(
      color: JVxColors.dividerColor(Theme.of(context)),
      width: 1,
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
      var isBrightnessLight = Theme.of(context).brightness == Brightness.light;
      return ListTile(
        textColor: isBrightnessLight ? Theme.of(context).colorScheme.onPrimary : null,
        iconColor: isBrightnessLight ? Theme.of(context).colorScheme.onPrimary : null,
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
