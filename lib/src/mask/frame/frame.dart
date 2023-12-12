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

import '../../flutter_ui.dart';
import '../../model/command/api/logout_command.dart';
import '../../service/api/i_api_service.dart';
import '../../service/apps/i_app_service.dart';
import '../../service/command/i_command_service.dart';
import '../../service/config/i_config_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../jvx_overlay.dart';
import '../login/default/cards/change_password.dart';
import 'mobile_frame.dart';
import 'web_frame.dart';

typedef FrameBuilder = Widget Function(BuildContext context, bool isOffline);

abstract class Frame extends StatefulWidget {
  final FrameBuilder builder;
  final bool isOffline;

  const Frame({
    super.key,
    required this.builder,
    required this.isOffline,
  });

  /// Finds the [FrameState] from the closest instance of this class that
  /// encloses the given context.
  static FrameState of(BuildContext context) {
    final FrameState? result = maybeOf(context);
    if (result != null) {
      return result;
    }
    throw FlutterError.fromParts([
      ErrorSummary(
        "Frame.of() called with a context that does not contain a Frame.",
      ),
      context.describeElement("The context used was"),
    ]);
  }

  /// Finds the [FrameState] from the closest instance of this class that
  /// encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will return null.
  /// To throw an exception instead, use [of] instead of this function.
  static FrameState? maybeOf(BuildContext? context) {
    return context?.findAncestorStateOfType<FrameState>();
  }

  void openSettings(BuildContext context) {
    IUiService().routeToSettings();
  }

  void changePassword() {
    IUiService().openDialog(
      pBuilder: (_) => ChangePassword.asDialog(
        username: IConfigService().userInfo.value?.userName,
      ),
      pIsDismissible: true,
    );
  }

  void logoutOrRestart() {
    if (IApiService().getRepository().cancelledSessionExpired.value) {
      IAppService().startApp();
    } else {
      ICommandService().sendCommand(LogoutCommand(reason: "Drawer menu logout"));
    }
  }

  factory Frame.getFrame(
    bool isWeb, {
    Key? key,
    required FrameBuilder builder,
    required bool isOffline,
  }) {
    if (isWeb) {
      return WebFrame(
        key: key,
        builder: builder,
        isOffline: isOffline,
      );
    } else {
      return MobileFrame(
        key: key,
        builder: builder,
        isOffline: isOffline,
      );
    }
  }

  static Widget wrapWithFrame({
    Key? key,
    required FrameBuilder builder,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: IConfigService().offline,
      builder: (context, isOffline, child) {
        return Frame.getFrame(
          key: key,
          Frame.isWebFrame(),
          builder: builder,
          isOffline: isOffline,
        );
      },
    );
  }

  /// Whether the currently used frame is [WebFrame].
  static bool isWebFrame() {
    if (IUiService().mobileOnly.value) {
      return false;
    }
    return IUiService().webOnly.value || kIsWeb;
  }
}

abstract class FrameState extends State<Frame> {
  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => PageStorage(
        bucket: JVxOverlay.of(context).storageBucket,
        child: Builder(
          builder: (context) => widget.builder.call(
            context,
            widget.isOffline,
          ),
        ),
      );

  List<Widget> getActions() {
    List<Widget> actions = [];

    IUiService().getAppManager()?.getAdditionalActions().forEach((element) {
      actions.add(element);
    });

    if (IUiService().applicationParameters.value.designModeAllowed) {
      actions.add(
        ValueListenableBuilder(
          valueListenable: IUiService().designMode,
          builder: (context, designMode, _) {
            return IconButton(
              tooltip:
                  "${FlutterUI.translate("Design Mode")}:${designMode ? FlutterUI.translate("On") : FlutterUI.translate("Off")}",
              splashRadius: kToolbarHeight / 2,
              onPressed: () {
                IUiService().updateDesignMode(!designMode);
              },
              icon: Icon(
                designMode ? Icons.design_services : Icons.design_services_outlined,
                size: 26,
              ),
            );
          },
        ),
      );
    }

    return actions;
  }

  Widget? getDrawer(BuildContext context) => null;

  Widget? getEndDrawer(BuildContext context) => null;

  PreferredSizeWidget getAppBar({
    Widget? leading,
    Widget? title,
    double? titleSpacing,
    Color? backgroundColor,
    List<Widget>? actions,
  });

  Widget wrapBody(Widget body) => body;
}

abstract class InheritedFrame extends InheritedWidget {
  const InheritedFrame({
    super.key,
    required super.child,
  });
}
