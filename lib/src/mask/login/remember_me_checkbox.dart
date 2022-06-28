import 'package:flutter/material.dart';

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
    return Row(
      children: [
        Checkbox(
          value: widget.checkHolder.isChecked,
          onChanged: (value) => _onPress(),
        ),
        TextButton(
          onPressed: () => _onPress(),
          child: const Text("Remember me?"),
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
