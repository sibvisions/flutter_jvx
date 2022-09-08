import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../main.dart';
import '../../../mixin/config_service_mixin.dart';
import '../drawer/drawer_menu.dart';
import 'frame.dart';

class MobileFrame extends Frame {
  MobileFrame({
    super.key,
    required super.builder,
  });

  @override
  MobileFrameState createState() => MobileFrameState();
}

class MobileFrameState extends FrameState with ConfigServiceGetterMixin {
  @override
  List<Widget> getActions() {
    return [
      Builder(
        builder: (context) => IconButton(
          icon: const FaIcon(FontAwesomeIcons.ellipsisVertical),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        ),
      ),
    ];
  }

  @override
  PreferredSizeWidget getAppBar(List<Widget>? actions) {
    return AppBar(
      title: Text(FlutterJVx.translate("Menu")),
      centerTitle: false,
      actions: actions,
      backgroundColor: getConfigService().isOffline() ? Colors.grey.shade500 : null,
      elevation: getConfigService().isOffline() ? 0 : null,
    );
  }

  @override
  Widget? getEndDrawer() {
    return Builder(
      builder: (context) => DrawerMenu(
        onSettingsPressed: () => widget.openSettings(context),
        onChangePasswordPressed: widget.changePassword,
        onLogoutPressed: widget.logout,
      ),
    );
  }
}