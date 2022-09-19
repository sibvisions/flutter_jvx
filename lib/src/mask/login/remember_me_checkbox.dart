import 'package:flutter/material.dart';

import '../../../flutter_jvx.dart';

class CheckHolder {
  bool isChecked;

  CheckHolder({
    required this.isChecked,
  });
}

class RememberMeCheckbox extends StatefulWidget {
  final CheckHolder checkHolder;

  const RememberMeCheckbox({
    required this.checkHolder,
    Key? key,
  }) : super(key: key);

  @override
  State<RememberMeCheckbox> createState() => _RememberMeCheckboxState();
}

class _RememberMeCheckboxState extends State<RememberMeCheckbox> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(FlutterJVx.translate("Remember me?")),
      value: widget.checkHolder.isChecked,
      contentPadding: EdgeInsets.zero,
      onChanged: (newValue) => _onPress(),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  void _onPress() {
    setState(() {
      widget.checkHolder.isChecked = !widget.checkHolder.isChecked;
    });
  }
}
