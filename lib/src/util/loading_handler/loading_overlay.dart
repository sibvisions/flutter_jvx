import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../services.dart';

class LoadingOverlay extends StatefulWidget {
  final Widget? child;

  const LoadingOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  static LoadingOverlayState? of(BuildContext? context) {
    return context?.findAncestorStateOfType<LoadingOverlayState>();
  }

  @override
  State<LoadingOverlay> createState() => LoadingOverlayState();
}

class LoadingOverlayState extends State<LoadingOverlay> {
  GlobalKey<FramesWidgetState> framesKey = GlobalKey();
  GlobalKey<DialogsWidgetState> dialogsKey = GlobalKey();

  Future? _loadingDelayFuture;
  bool _loading = false;

  bool get isLoading => _loading;

  void refresh() {
    setState(() {});
  }

  void refreshFrames() {
    framesKey.currentState?.setState(() {});
  }

  void refreshDialogs() {
    dialogsKey.currentState?.setState(() {});
  }

  void show(Duration delay) {
    if (!_loading) {
      _loadingDelayFuture = Future.delayed(delay);
      _loading = true;

      if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
        SchedulerBinding.instance.addPostFrameCallback((_) {});
        return;
      }
      setState(() {});
    }
  }

  void hide() {
    if (_loading) {
      _loading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        FramesWidget(key: framesKey),
        DialogsWidget(key: dialogsKey),
        if (_loading)
          FutureBuilder(
            future: _loadingDelayFuture,
            builder: (context, snapshot) {
              return Stack(
                children: getLoadingIndicator(context, snapshot.connectionState == ConnectionState.done),
              );
            },
          ),
      ],
    );
  }

  List<Widget> getLoadingIndicator(BuildContext context, bool delayFinished) {
    return [
      Opacity(
        opacity: delayFinished ? 0.7 : 0,
        child: const ModalBarrier(dismissible: false, color: Colors.black),
      ),
      if (delayFinished)
        Center(
          child: Container(
            width: 100.0,
            height: 100.0,
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [CircularProgressIndicator.adaptive()],
            ),
          ),
        ),
    ];
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
