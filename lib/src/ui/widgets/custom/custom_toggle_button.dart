import 'package:flutter/material.dart';

class CustomToggleButton extends StatelessWidget {
  final double minWidth;
  final EdgeInsets? padding;
  final bool enabled;
  final void Function() onPressed;
  final Color? background;
  final Widget child;
  final ShapeBorder? shape;

  const CustomToggleButton(
      {Key? key,
      required this.minWidth,
      this.padding,
      required this.enabled,
      required this.onPressed,
      this.background,
      this.shape,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(4),
        child: ButtonTheme(
            minWidth: minWidth,
            padding: padding,
            layoutBehavior: ButtonBarLayoutBehavior.constrained,
            shape: shape,
            child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: enabled ? onPressed : null,
                  style: ButtonStyle(
                      backgroundColor: enabled
                          ? MaterialStateProperty.all(
                              background ?? Theme.of(context).primaryColor)
                          : MaterialStateProperty.all(Colors.grey.shade300),
                      elevation: MaterialStateProperty.all(2),
                      overlayColor: MaterialStateProperty.all(
                          background ?? Theme.of(context).primaryColor)),
                  child: child,
                ))));
  }
}
