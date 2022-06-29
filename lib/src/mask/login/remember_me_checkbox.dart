import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';

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

class _RememberMeCheckboxState extends State<RememberMeCheckbox> with ConfigServiceMixin {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.checkHolder.isChecked,
          onChanged: (value) => _onPress(),
        ),
        TextButton(
          onPressed: () => _onPress(),
          child: Text(configService.translateText("Remember me?")),
        ),
      ],
    );
  }

  void _onPress() {
    setState(() {
      widget.checkHolder.isChecked = !widget.checkHolder.isChecked;
    });
  }
}
