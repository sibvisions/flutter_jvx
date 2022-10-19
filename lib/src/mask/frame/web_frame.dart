import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/parse_util.dart';
import '../../model/response/device_status_response.dart';
import '../drawer/web_menu.dart';
import '../setting/settings_page.dart';
import '../state/app_style.dart';
import '../state/loading_bar.dart';
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
  late LayoutMode lastMode;
  late bool showWebMenu;

  @override
  void initState() {
    super.initState();
    showWebMenu = IConfigService().getLayoutMode().value != LayoutMode.Mini;
    lastMode = IConfigService().getLayoutMode().value;
    IConfigService().getLayoutMode().addListener(updatedLayoutMode);
  }

  @override
  void dispose() {
    IConfigService().getLayoutMode().removeListener(updatedLayoutMode);
    super.dispose();
  }

  ///Handle menu status on [LayoutMode] change
  ///Examples:
  ///* Close menu when changing to [LayoutMode.Mini]
  ///* Reopen menu when changing from [LayoutMode.Mini]
  void updatedLayoutMode() {
    var newMode = IConfigService().getLayoutMode().value;
    if (lastMode != newMode) {
      if (newMode == LayoutMode.Mini && showWebMenu) {
        showWebMenu = false;
        setState(() {});
      }
      if (newMode != LayoutMode.Mini && lastMode == LayoutMode.Mini && !showWebMenu) {
        showWebMenu = true;
        setState(() {});
      }
    }
    lastMode = newMode;
  }

  void toggleWebMenu() {
    showWebMenu = !showWebMenu;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => InheritedWebFrame(
        showMenu: showWebMenu,
        child: super.build(context),
      );

  @override
  PreferredSizeWidget getAppBar(List<Widget>? actions) {
    var profileImage = IConfigService().getUserInfo()?.profileImage;
    var appStyle = AppStyle.of(context)!.applicationStyle!;
    Color? topMenuColor = ParseUtil.parseHexColor(appStyle['web.topmenu.color']);
    Color? iconColor = ParseUtil.parseHexColor(appStyle['web.topmenu.iconColor']);
    String? imagePath = appStyle['web.topmenu.image'];

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
                  "assets/images/logo.png",
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
          child: Builder(
            builder: (context) => WebMenu(
              showWebMenu: InheritedWebFrame.of(context).showMenu,
              onSettingsPressed: () => widget.openSettings(context),
              onChangePasswordPressed: widget.changePassword,
              onLogoutPressed: widget.logout,
            ),
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

class InheritedWebFrame extends InheritedFrame {
  final bool showMenu;

  const InheritedWebFrame({
    super.key,
    required this.showMenu,
    required super.child,
  });

  static InheritedWebFrame of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<InheritedWebFrame>()!;

  @override
  bool updateShouldNotify(covariant InheritedWebFrame oldWidget) {
    return showMenu != oldWidget.showMenu;
  }
}
