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
import '../../service/config/config_controller.dart';
import '../../service/ui/i_ui_service.dart';
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
        "FlutterUI.of() called with a context that does not contain a FlutterUI.",
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
        username: ConfigController().userInfo.value?.userName,
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
    required bool forceMobile,
    required bool forceWeb,
    required FrameBuilder builder,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: ConfigController().offline,
      builder: (context, isOffline, child) {
        if (forceMobile) {
          return Frame.getFrame(
            key: key,
            false,
            builder: builder,
            isOffline: isOffline,
          );
        }
        if (forceWeb) {
          return Frame.getFrame(
            key: key,
            true,
            builder: builder,
            isOffline: isOffline,
          );
        }
        return Frame.getFrame(
          key: key,
          kIsWeb,
          builder: builder,
          isOffline: isOffline,
        );
      },
    );
  }

  /// Whether the currently used frame is [WebFrame].
  static bool isWebFrame() {
    return (!ConfigController().mobileOnly.value && kIsWeb) || ConfigController().webOnly.value || kIsWeb;
  }
}

abstract class FrameState extends State<Frame> {
  @override
  Widget build(BuildContext context) => PageStorage(
        bucket: pageStorageBucket,
        child: Builder(
          builder: (context) => widget.builder.call(
            context,
            widget.isOffline,
          ),
        ),
      );

  List<Widget> getActions() => [];

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
