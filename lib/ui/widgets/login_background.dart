import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/ui/tools/arc_clipper.dart';
import 'package:jvx_mobile_v3/utils/check_if_image_exists.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class LoginBackground extends StatelessWidget {
  final showIcon;
  final image;
  LoginBackground({this.showIcon = true, this.image = 'assets/images/sib_visions.jpg'});

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
            showIcon
                ? new Center(
                    child: SizedBox(
                        height: deviceSize.height / 8,
                        width: deviceSize.width / 2,
                        child: FlutterLogo(
                          colors: Colors.yellow,
                        )),
                  )
                : new Container(
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF${globals.applicationStyle.loginBackground}'))
                    ),
                    width: double.infinity,
                    child: checkIfImageExists('${globals.dir}${globals.applicationStyle.loginIcon}')
                        ? Image.file(
                            File('${globals.dir}${globals.applicationStyle.loginIcon}'),
                            fit: BoxFit.fitHeight
                          )
                        : new Container())
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
      children: <Widget>[topHalf(context), bottomHalf],
    );
  }
}
