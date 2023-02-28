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

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rxdart/rxdart.dart';

import '../model/command/api/device_status_command.dart';
import '../model/command/ui/set_focus_command.dart';
import '../service/command/i_command_service.dart';
import '../service/config/config_controller.dart';
import '../service/ui/i_ui_service.dart';
import 'state/app_style.dart';
import 'state/loading_bar.dart';

class JVxOverlay extends StatefulWidget {
  final Widget? child;

  const JVxOverlay({
    super.key,
    required this.child,
  });

  /// Finds the [JVxOverlayState] from the closest instance of this class that
  /// encloses the given context.
  static JVxOverlayState of(BuildContext context) {
    final JVxOverlayState? result = maybeOf(context);
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

  /// Finds the [JVxOverlayState] from the closest instance of this class that
  /// encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will return null.
  /// To throw an exception instead, use [of] instead of this function.
  static JVxOverlayState? maybeOf(BuildContext? context) {
    return context?.findAncestorStateOfType<JVxOverlayState>();
  }

  @override
  State<JVxOverlay> createState() => JVxOverlayState();
}

class JVxOverlayState extends State<JVxOverlay> {
  /// Report device status to server
  final BehaviorSubject<Size> subject = BehaviorSubject<Size>();

  GlobalKey<DialogsWidgetState> dialogsKey = GlobalKey();

  bool loading = false;
  Future? _loadingDelayFuture;
  bool forceDisableBarrier = false;

  void refreshDialogs() {
    setState(() {});
  }

  /// Overrides the modal barrier while [loading] is true.
  ///
  /// Do not forget to re-enable it with [overrideModalBarrier(false)]!
  void overrideModalBarrier(bool forceDisableBarrier) {
    setState(() {
      this.forceDisableBarrier = forceDisableBarrier;
    });
  }

  void showLoading(Duration delay) {
    if (!loading) {
      _loadingDelayFuture = Future.delayed(delay);
      loading = true;

      if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
        SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));
        return;
      }

      setState(() {});
    }
  }

  void hideLoading() {
    if (loading) {
      loading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    subject.throttleTime(const Duration(milliseconds: 8), trailing: true).listen((size) {
      if (IUiService().clientId.value != null && !ConfigController().offline.value) {
        ICommandService().sendCommand(DeviceStatusCommand(
          screenWidth: size.width,
          screenHeight: size.height,
          reason: "Device Size changed",
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    subject.add(MediaQuery.of(context).size);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();

        IUiService().sendCommand(
          SetFocusCommand(componentId: IUiService().getFocus()?.id, focus: false, reason: "Unfocus, pressed somewhere"),
        );
      },
      child: AppStyle(
        applicationStyle: ConfigController().applicationStyle.value,
        applicationSettings: IUiService().applicationSettings.value,
        child: FutureBuilder(
          future: _loadingDelayFuture,
          builder: (context, snapshot) {
            return LoadingBar(
              show: loading && snapshot.connectionState == ConnectionState.done,
              child: Stack(
                children: [
                  if (widget.child != null) widget.child!,
                  DialogsWidget(key: dialogsKey),
                  if (loading && !forceDisableBarrier)
                    const ModalBarrier(
                      dismissible: false,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class DialogsWidget extends StatefulWidget {
  const DialogsWidget({super.key});

  @override
  State<DialogsWidget> createState() => DialogsWidgetState();
}

class DialogsWidgetState extends State<DialogsWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: _getDialogs());
  }

  List<Widget> _getDialogs() {
    return IUiService()
        .getJVxDialogs()
        .map(
          (e) => Stack(
            children: [
              Opacity(
                opacity: 0.7,
                child: ModalBarrier(
                  dismissible: e.dismissible,
                  color: Colors.black54,
                  onDismiss: () {
                    e.onClose();
                    IUiService().closeJVxDialog(e);
                    setState(() {});
                  },
                ),
              ),
              e,
            ],
          ),
        )
        .toList();
  }
}
