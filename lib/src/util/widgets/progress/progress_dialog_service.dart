import 'package:flutter/material.dart';

import '../../../flutter_ui.dart';
import 'progress_dialog_widget.dart';

class ProgressDialogService {
  static OverlayEntry? _entry;
  static final GlobalKey<ProgressDialogState> dialogKey = GlobalKey<ProgressDialogState>();

  static void show(Config config) {
    _entry?.remove(); //to be sure

    _entry = OverlayEntry(
      builder: (context) => PopScope(
        canPop: false, // don't allow navigation "behind"
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          //we don't hide the overlay
        },
        child: Container(
          color: Colors.black54, // Background layer
          child: ProgressDialogWidget(
            key: dialogKey,
            config: config,
          ),
        ),
      ),
    );

    rootNavigatorKey.currentState?.insert(_entry!);
  }

  static void update(Config config) {
    dialogKey.currentState?.update(config);
  }

  static Future<void> hide() async {
    await dialogKey.currentState?.reverse();

    _entry?.remove();
    _entry = null;
  }
}