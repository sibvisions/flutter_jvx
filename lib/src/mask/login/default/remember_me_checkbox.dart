import 'package:flutter/material.dart';

import '../../../flutter_ui.dart';

class RememberMeCheckbox extends StatelessWidget {
  final bool value;
  final Function() onToggle;

  const RememberMeCheckbox(
    this.value, {
    super.key,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(FlutterUI.translate("Remember me?")),
      value: value,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      onChanged: (newValue) => onToggle.call(),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
