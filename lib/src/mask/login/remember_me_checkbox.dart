import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../mixin/config_service_mixin.dart';

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

class _RememberMeCheckboxState extends State<RememberMeCheckbox> with ConfigServiceGetterMixin {
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
