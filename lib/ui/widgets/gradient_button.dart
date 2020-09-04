import 'package:flutter/material.dart';
import '../../utils/uidata.dart';
import '../../utils/globals.dart' as globals;

class GradientButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final String text;

  GradientButton({@required this.onPressed, @required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      color: Colors.transparent,
      shape: globals.applicationStyle?.buttonShape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onPressed,
        splashColor: UIData.ui_kit_color_2,
        child: Ink(
          height: 50.0,
          decoration: ShapeDecoration(
              shape: globals.applicationStyle?.buttonShape ??
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
              gradient: LinearGradient(
                colors: UIData.kitGradients2,
              )),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 20.0),
            ),
          ),
        ),
      ),
    );
  }
}
