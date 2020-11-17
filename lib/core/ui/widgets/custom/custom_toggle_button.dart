import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';

class CustomToggleButton extends StatelessWidget {
  final double minWidth;
  final EdgeInsets padding;
  final bool enabled;
  final Function onPressed;
  final Color background;
  final Widget child;
  final ShapeBorder shape;

  const CustomToggleButton(
      {Key key,
      this.minWidth,
      this.padding,
      this.enabled,
      this.onPressed,
      this.background,
      this.shape,
      this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(4),
        child: ButtonTheme(
            minWidth: minWidth,
            padding: padding,
            layoutBehavior: ButtonBarLayoutBehavior.constrained,
            shape: this.shape ?? null,
            child: SizedBox(
                height: 50,
                child: RaisedButton(
                  onPressed: this.enabled != null && this.enabled ? onPressed : null,
                  color: this.background != null
                      ? this.background
                      : Theme.of(context).primaryColor,
                  elevation: 2,
                  disabledColor: Colors.grey.shade300,
                  child: child,
                  splashColor: this.background != null
                      ? TinyColor(this.background).darken().color
                      : Theme.of(context).primaryColor,
                ))));
  }
}
