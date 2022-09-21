import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../services.dart';
import '../../model/command/api/logout_command.dart';
import '../setting/widgets/change_password.dart';
import 'mobile_frame.dart';
import 'web_frame.dart';

abstract class Frame extends StatefulWidget {
  final WidgetBuilder builder;

  const Frame({
    super.key,
    required this.builder,
  });

  void openSettings(BuildContext context) {
    IUiService().routeToSettings();
  }

  void changePassword() {
    IUiService().openDialog(
      pBuilder: (_) => ChangePassword(
        username: IConfigService().getUserInfo()?.userName,
      ),
      pIsDismissible: true,
    );
  }

  void logout() {
    LogoutCommand logoutCommand = LogoutCommand(reason: "Drawer menu logout");
    IUiService().sendCommand(logoutCommand);
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
  static FrameState? of(BuildContext context) => context.findAncestorStateOfType<FrameState>();

  @override
  Widget build(BuildContext context) => widget.builder.call(context);

  List<Widget> getActions() => [];

  Widget? getEndDrawer() => null;

  PreferredSizeWidget getAppBar(List<Widget>? actions);

  Widget wrapBody(Widget body) => body;
}
