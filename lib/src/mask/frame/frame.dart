import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../model/command/api/logout_command.dart';
import '../setting/widgets/change_password.dart';
import 'mobile_frame.dart';
import 'web_frame.dart';

abstract class Frame extends StatefulWidget with ConfigServiceGetterMixin, UiServiceGetterMixin {
  final Widget child;
  final GlobalKey? childKey;

  Frame({
    super.key,
    required this.child,
    this.childKey,
  });

  void openSettings(BuildContext context) {
    getUiService().routeToSettings();
  }

  void changePassword() {
    getUiService().openDialog(
      pBuilder: (_) => ChangePassword(
        username: getConfigService().getUserInfo()?.userName,
      ),
      pIsDismissible: true,
    );
  }

  void logout() {
    LogoutCommand logoutCommand = LogoutCommand(reason: "Drawer menu logout");
    getUiService().sendCommand(logoutCommand);
  }

  factory Frame.getFrame(
    bool isWeb, {
    Key? key,
    GlobalKey? childKey,
    required Widget child,
  }) {
    if (isWeb) {
      return WebFrame(key: key, childKey: childKey, child: child);
    } else {
      return MobileFrame(key: key, childKey: childKey, child: child);
    }
  }

  static FrameState? of(BuildContext context) => context.findAncestorStateOfType<FrameState>();

  static Widget wrapWithFrame(
      {Key? key, GlobalKey? childKey, bool forceMobile = false, bool forceWeb = false, required Widget child}) {
    if (forceMobile) {
      return Frame.getFrame(
        key: key,
        false,
        childKey: childKey,
        child: child,
      );
    }
    if (forceWeb) {
      return Frame.getFrame(
        key: key,
        true,
        childKey: childKey,
        child: child,
      );
    }
    return OrientationBuilder(
      builder: (context, orientation) {
        return Frame.getFrame(
          key: key,
          orientation == Orientation.landscape && kIsWeb,
          childKey: childKey,
          child: child,
        );
      },
    );
  }
}

abstract class FrameState extends State<Frame> {
  // bool showWebMenu = true;

  @override
  Widget build(BuildContext context) => widget.child;

  List<Widget> getActions() => [];

  Widget? getEndDrawer() => null;

  PreferredSizeWidget getAppBar(List<Widget>? actions);

  Widget wrapBody(Widget body) => body;

// void toggleWebMenu() {
//   setState(() => showWebMenu = !showWebMenu);
// }
}
