import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/ui/tools/arc_clipper.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class LoginBackground extends StatelessWidget {
  LoginBackground();

  Widget topHalf1(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 100,
      height: 100,
      child: Stack(
        children: <Widget>[
          new Container(
              decoration: BoxDecoration(color: Colors.white),
              width: double.infinity,
              child: (globals.applicationStyle == null || globals.applicationStyle?.loginIcon == null)
                  ? Image.asset(
                      'assets/images/sib_visions.jpg',
                      fit: BoxFit.fitHeight,
                    )
                  : Image.file(
                      File(
                          '${globals.dir}${globals.applicationStyle.loginIcon}'),
                      fit: BoxFit.fitHeight))
        ],
      ),
    );
  }

  Widget topHalf2(BuildContext context) {
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
                child: (globals.applicationStyle == null || globals.applicationStyle?.loginIcon == null)
                    ? Image.asset('assets/images/sibvisions.png',
                        fit: BoxFit.fitHeight)
                    : Image.file(
                        File('${globals.dir}${globals.applicationStyle.loginIcon}'),
                        fit: BoxFit.fitHeight),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget topHalf(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return new Flexible(
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
            FlutterLogo(
            colors: Colors.yellow,
            ),
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
    return new Column(
      children: <Widget>[topHalf2(context), bottomHalf],
    );
  }
}
