import 'package:flutter/material.dart';

import '../../../../models/state/app_state.dart';

class GradientButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final String text;
  final AppState appState;

  const GradientButton(
      {Key? key,
      required this.onPressed,
      required this.text,
      required this.appState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      color: Colors.transparent,
      shape: appState.applicationStyle?.buttonShape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onPressed,
        splashColor: Theme.of(context).primaryColor,
        child: Ink(
          height: 50.0,
          decoration: ShapeDecoration(
              shape: appState.applicationStyle?.buttonShape ??
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor
                ],
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
