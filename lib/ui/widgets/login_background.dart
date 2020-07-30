import 'dart:io';
import 'dart:convert' as utf8;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
                    : !kIsWeb
                        ? Image.file(
                            File(
                                '${globals.dir}${globals.applicationStyle.loginLogo}'),
                            fit: BoxFit.fitHeight)
                        : Image.memory(utf8.base64Decode(
                            globals.files[globals.applicationStyle.loginIcon])),
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
    Widget widget;

    if ((globals.applicationStyle != null &&
        globals.applicationStyle?.loginIcon != null)) {
      widget = Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: !kIsWeb
                      ? FileImage(File(
                          '${globals.dir}${globals.applicationStyle.loginIcon}'))
                      : MemoryImage(utf8.base64Decode(
                          globals.files[globals.applicationStyle.loginIcon])),
                  fit: BoxFit.cover)),
          child: Column(
            children: <Widget>[topHalf(context), bottomHalf],
          ));
    } else {
      widget = Column(
        children: <Widget>[topHalf(context), bottomHalf],
      );
    }

    return SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(child: widget)));
  }
}
