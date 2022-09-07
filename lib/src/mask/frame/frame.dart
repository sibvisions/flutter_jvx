import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../model/command/api/logout_command.dart';
import '../setting/widgets/change_password.dart';
import 'mobile_frame.dart';
import 'web_frame.dart';

abstract class Frame extends StatefulWidget with ConfigServiceGetterMixin, UiServiceGetterMixin {
  final WidgetBuilder builder;

  Frame({
    super.key,
    required this.builder,
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
    required WidgetBuilder builder,
  }) {
    if (isWeb) {
      return WebFrame(key: key, builder: builder);
    } else {
      return MobileFrame(key: key, builder: builder);
    }
  }

  static FrameState? of(BuildContext context) => context.findAncestorStateOfType<FrameState>();

  static Widget wrapWithFrame(
      {Key? key, required bool forceMobile, required bool forceWeb, required WidgetBuilder builder}) {
    if (forceMobile) {
      return Frame.getFrame(
        key: key,
        false,
        builder: builder,
      );
    }
    if (forceWeb) {
      return Frame.getFrame(
        key: key,
        true,
        builder: builder,
      );
    }
    return OrientationBuilder(
      builder: (context, orientation) {
        return Frame.getFrame(
          key: key,
          orientation == Orientation.landscape && kIsWeb,
          builder: builder,
        );
      },
    );
  }
}

abstract class FrameState extends State<Frame> {
  @override
  Widget build(BuildContext context) => widget.builder.call(context);

  List<Widget> getActions() => [];

  Widget? getEndDrawer() => null;

  PreferredSizeWidget getAppBar(List<Widget>? actions);

  Widget wrapBody(Widget body) => body;
}
