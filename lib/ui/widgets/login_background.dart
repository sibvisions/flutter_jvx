import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/ui/tools/arc_clipper.dart';
import 'package:jvx_mobile_v3/utils/check_if_image_exists.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class LoginBackground extends StatelessWidget {
  LoginBackground();

  Widget topHalf(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 100,
      height: 100,
      child: Stack(
        children: <Widget>[
          new Container(
              decoration: BoxDecoration(color: Colors.white),
              width: double.infinity,
              child: globals.applicationStyle == null ? Image.asset(
                'assets/images/sib_visions.jpg',
                fit: BoxFit.fitHeight,
              ) : Image.file(
                File('${globals.dir}${globals.applicationStyle.loginIcon}'),
                fit: BoxFit.fitHeight
              )
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return topHalf(context);
  }
}
