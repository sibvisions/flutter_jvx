import 'dart:io';
import 'package:flutter/material.dart';
import '../../ui/tools/arc_clipper.dart';
import '../../utils/uidata.dart';
import '../../utils/globals.dart' as globals;

class LoginBackground extends StatelessWidget {
  LoginBackground();

  Widget topHalf(BuildContext context) {
    return Flexible(
      flex: 2,
      child: ClipPath(
        clipper: new ArcClipper(),
        child: Stack(
          children: <Widget>[
            new Container(
              decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                colors: UIData.kitGradients2,
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: (globals.applicationStyle == null ||
                        globals.applicationStyle?.loginLogo == null)
                    ? Image.asset(
                        globals.package
                            ? 'packages/jvx_flutterclient/assets/images/sibvisions.png'
                            : 'assets/images/sibvisions.png',
                        fit: BoxFit.fitHeight)
                    : Image.file(
                        File(
                            '${globals.dir}${globals.applicationStyle.loginLogo}'),
                        fit: BoxFit.fitHeight),
              ),
            )
          ],
        ),
      ),
    );
  }

  final bottomHalf = new Flexible(
    flex: 3,
    child: new Container(),
  );

  @override
  Widget build(BuildContext context) {
    if ((globals.applicationStyle != null &&
        globals.applicationStyle?.loginIcon != null)) {
      return Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: FileImage(File(
                      '${globals.dir}${globals.applicationStyle.loginIcon}')),
                  fit: BoxFit.cover)),
          child: Column(
            children: <Widget>[topHalf(context), bottomHalf],
          ));
    } else {
      return Column(
        children: <Widget>[topHalf(context), bottomHalf],
      );
    }
  }
}
