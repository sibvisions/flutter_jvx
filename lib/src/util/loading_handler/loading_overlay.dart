import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LoadingOverlay extends StatefulWidget {
  final Widget? child;

  const LoadingOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  static LoadingOverlayState of(BuildContext context) {
    return context.findAncestorStateOfType<LoadingOverlayState>()!;
  }

  @override
  State<LoadingOverlay> createState() => LoadingOverlayState();
}

class LoadingOverlayState extends State<LoadingOverlay> {
  bool _loading = false;

  Duration? _loadingDelay;

  bool get isLoading => _loading;

  void show(Duration delay) {
    if (!_loading) {
      _loadingDelay = delay;
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
        if (_loading)
          FutureBuilder(
            future: Future.delayed(_loadingDelay!),
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
