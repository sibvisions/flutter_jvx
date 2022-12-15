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
import '../service/config/config_service.dart';
import '../service/ui/i_ui_service.dart';
import 'state/app_style.dart';
import 'state/loading_bar.dart';

class JVxOverlay extends StatefulWidget {
  final Widget? child;

  const JVxOverlay({
    super.key,
    required this.child,
  });

  @override
  State<JVxOverlay> createState() => JVxOverlayState();
}

class JVxOverlayState extends State<JVxOverlay> {
  /// Report device status to server
  final BehaviorSubject<Size> subject = BehaviorSubject<Size>();

  GlobalKey<FramesWidgetState> framesKey = GlobalKey();
  GlobalKey<DialogsWidgetState> dialogsKey = GlobalKey();

  bool loading = false;
  Future? _loadingDelayFuture;

  static JVxOverlayState? of(BuildContext? context) => context?.findAncestorStateOfType<JVxOverlayState>();

  void refreshFrames() {
    framesKey.currentState?.setState(() {});
  }

  void refreshDialogs() {
    dialogsKey.currentState?.setState(() {});
  }

  void showLoading(Duration delay) {
    if (!loading) {
      _loadingDelayFuture = Future.delayed(delay);
      loading = true;

      if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
        SchedulerBinding.instance.addPostFrameCallback((_) {});
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
      if (ConfigService().getClientId() != null && !ConfigService().isOffline()) {
        IUiService().sendCommand(DeviceStatusCommand(
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
      },
      child: AppStyle(
        applicationStyle: ConfigService().getAppStyle(),
        applicationSettings: ConfigService().getApplicationSettings(),
        child: FutureBuilder(
          future: _loadingDelayFuture,
          builder: (context, snapshot) {
            return LoadingBar(
              show: loading && snapshot.connectionState == ConnectionState.done,
              child: Stack(
                children: [
                  widget.child!,
                  FramesWidget(key: framesKey),
                  DialogsWidget(key: dialogsKey),
                  if (loading)
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

class FramesWidget extends StatefulWidget {
  const FramesWidget({super.key});

  @override
  State<FramesWidget> createState() => FramesWidgetState();
}

class FramesWidgetState extends State<FramesWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: _getFrames());
  }

  List<Widget> _getFrames() {
    return IUiService()
        .getFrames()
        .values
        .map(
          (e) => Stack(
            children: [
              Opacity(
                opacity: 0.7,
                child: ModalBarrier(
                  dismissible: e.command.closable,
                  color: Colors.black54,
                  onDismiss: () {
                    e.close();
                    IUiService().closeFrame(componentId: e.command.componentId);
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
        .getFrameDialogs()
        .map(
          (e) => Stack(
            children: [
              Opacity(
                opacity: 0.7,
                child: ModalBarrier(
                  dismissible: e.dismissible,
                  color: Colors.black54,
                  onDismiss: () {
                    IUiService().closeFrameDialog(e);
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
