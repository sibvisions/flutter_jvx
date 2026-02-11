import 'package:flutter/material.dart';

import '../../../flutter_ui.dart';
import 'progress_dialog_widget.dart';

class ProgressDialogService {
  static OverlayEntry? _entry;
  static final GlobalKey<ProgressDialogState> dialogKey = GlobalKey<ProgressDialogState>();

  static void show(Config config) {
    _entry?.remove(); //to be sure

    _entry = OverlayEntry(
      builder: (context) {

        bool dismissible = config.barrierDismissible ?? false;

        ProgressDialogState? state = dialogKey.currentState;
        if (state != null) {
          dismissible = state.isDismissible();
        }

        Widget barrier = Container(color: Colors.black54);

        if (dismissible) {
          barrier = GestureDetector(
              onTap: () async {
                await hide();
              },
              child: barrier
          );
        }

        //PopScope is useless in normal usage because the navigator is behind, so
        //we handle the pop in FlutterUI.didPopRoute.
        //This code here is only for completeness
        return PopScope(
          canPop: !dismissible,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            hide();
          },
          child: Stack(
            children: [
              barrier,
              ProgressDialogWidget(
                key: dialogKey,
                config: config,
              )
            ],
          ),
        );
      },
    );

    rootNavigatorKey.currentState?.insert(_entry!);
  }

  static void update(Config config) {
    if (_entry != null) {
      if ((dialogKey.currentState?.isDismissible() ?? false) != (config.barrierDismissible ?? false)) {
        _entry!.markNeedsBuild();
      }
    }

    dialogKey.currentState?.update(config);
  }

  static Future<void> hide() async {
    await dialogKey.currentState?.reverse();

    _entry?.remove();
    _entry = null;
  }

  static bool isShown() {
    return _entry != null;
  }

  static bool isDismissible() {
    return dialogKey.currentState?.isDismissible() ?? false;
  }
}