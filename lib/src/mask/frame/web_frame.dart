import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/parse_util.dart';
import '../drawer/web_menu.dart';
import '../loading_bar.dart';
import '../setting/settings_page.dart';
import 'frame.dart';

class WebFrame extends Frame {
  const WebFrame({
    super.key,
    required super.builder,
  });

  @override
  void openSettings(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  FrameState createState() => WebFrameState();
}

class WebFrameState extends FrameState {
  static const double spacing = 15.0;
  bool showWebMenu = true;

  void toggleWebMenu() {
    showWebMenu = !showWebMenu;
    setState(() {});
  }

  @override
  PreferredSizeWidget getAppBar(List<Widget>? actions) {
    var profileImage = IConfigService().getUserInfo()?.profileImage;
    Color? topMenuColor = ParseUtil.parseHexColor(IConfigService().getAppStyle()?["web.topmenu.color"]);
    Color? iconColor = ParseUtil.parseHexColor(IConfigService().getAppStyle()?["web.topmenu.iconColor"]);
    String? imagePath = IConfigService().getAppStyle()?["web.topmenu.image"];

    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: FaIcon(
            FontAwesomeIcons.bars,
            color: iconColor,
          ),
          onPressed: () => toggleWebMenu(),
        ),
      ),
      titleSpacing: 0.0,
      title: SizedBox(
        height: kToolbarHeight,
        child: imagePath != null
            ? ImageLoader.loadImage(imagePath)
            : Image.asset(
                ImageLoader.getAssetPath(
                  FlutterJVx.package,
                  'assets/images/logo.png',
                ),
                fit: BoxFit.scaleDown,
              ),
      ),
      centerTitle: false,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: FaIcon(
              FontAwesomeIcons.gear,
              color: iconColor,
            ),
            onPressed: () => widget.openSettings(context),
          ),
        ),
        const Padding(padding: EdgeInsets.only(right: spacing)),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.key,
            color: iconColor,
          ),
          onPressed: () => widget.changePassword(),
        ),
        const Padding(padding: EdgeInsets.only(right: spacing)),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.rightFromBracket,
            color: iconColor,
          ),
          onPressed: () => widget.logout(),
        ),
        const Padding(padding: EdgeInsets.only(right: spacing)),
        Builder(builder: (context) {
          return CircleAvatar(
            backgroundColor: Theme.of(context).backgroundColor,
            backgroundImage: profileImage != null ? MemoryImage(profileImage) : null,
            child: profileImage == null
                ? FaIcon(
                    FontAwesomeIcons.solidUser,
                    color: Colors.grey.shade400,
                    size: 23,
                  )
                : null,
          );
        }),
        const Padding(padding: EdgeInsets.only(right: spacing)),
      ],
      backgroundColor: IConfigService().isOffline() ? Colors.grey.shade500 : topMenuColor,
      elevation: IConfigService().isOffline() ? 0 : null,
    );
  }

  @override
  Widget wrapBody(Widget body) {
    Widget overrideBody = Row(children: [
      RepaintBoundary(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 250),
          child: WebMenu(
            showWebMenu: showWebMenu,
            onSettingsPressed: () => widget.openSettings(context),
            onChangePasswordPressed: widget.changePassword,
            onLogoutPressed: widget.logout,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: body,
      ),
    ]);

    return LoadingBar.wrapLoadingBar(overrideBody);
  }

  @override
  Widget? getEndDrawer() => Builder(
        builder: (context) {
          double screenWidth = MediaQuery.of(context).size.width;

          return SizedBox(
            width: max(screenWidth / 4, min(screenWidth, 300)),
            child: const SettingsPage(),
          );
        },
      );
}
