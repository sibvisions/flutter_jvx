import 'package:flutter/widgets.dart';

abstract class FrameDialog extends StatelessWidget {
  final bool dismissible;

  const FrameDialog({super.key, this.dismissible = false});

  void onClose() {}
}
