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

        return PopScope(
          canPop: dismissible, // don't allow navigation "behind"
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
}