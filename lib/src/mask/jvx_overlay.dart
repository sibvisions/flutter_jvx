import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rxdart/rxdart.dart';

import '../../services.dart';
import '../model/command/api/device_status_command.dart';
import 'loading_bar.dart';

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

  static JVxOverlayState? of(BuildContext? context) {
    return context?.findAncestorStateOfType<JVxOverlayState>();
  }

  void refreshFrames() {
    framesKey.currentState?.setState(() {});
  }

  void refreshDialogs() {
    dialogsKey.currentState?.setState(() {});
  }

  void showLoading(Duration delay) {
    if (!loading) {
      if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          loading = true;
        });
        return;
      }

      loading = true;
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
      if (IConfigService().getClientId() != null && !IConfigService().isOffline()) {
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
    return LoadingBar(
      show: loading,
      child: Stack(
        children: [
          if (widget.child != null)
            LayoutBuilder(builder: (context, constraints) {
              subject.add(Size(constraints.maxWidth, constraints.maxHeight));
              return widget.child!;
            }),
          FramesWidget(key: framesKey),
          DialogsWidget(key: dialogsKey),
          if (loading)
            const ModalBarrier(
              dismissible: false,
            ),
        ],
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
