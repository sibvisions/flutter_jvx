import 'dart:convert' as utf8;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../models/app/app_state.dart';
import 'arc_clipper.dart';

class LoginBackground extends StatelessWidget {
  final AppState appState;

  LoginBackground(this.appState);

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
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor
                ],
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: (appState.applicationStyle == null ||
                        this.appState.applicationStyle?.loginLogo == null)
                    ? Image.asset(
                        appState.package
                            ? 'packages/jvx_flutterclient/assets/images/logo_small.png'
                            : 'assets/images/logo_small.png',
                        fit: BoxFit.fitHeight)
                    : !kIsWeb
                        ? Image.file(
                            File(
                                '${this.appState.dir}${this.appState.applicationStyle?.loginLogo}'),
                            fit: BoxFit.fitHeight)
                        : Image.memory(utf8.base64Decode(this
                            .appState
                            .files[this.appState.applicationStyle?.loginLogo])),
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

    if ((appState.applicationStyle != null &&
        this.appState.applicationStyle?.loginIcon != null)) {
      widget = Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: !kIsWeb
                      ? File('${this.appState.dir}${this.appState.applicationStyle?.loginIcon}')
                              .existsSync()
                          ? FileImage(File(
                              '${this.appState.dir}${this.appState.applicationStyle?.loginIcon}'))
                          : AssetImage(appState.package
                              ? 'packages/jvx_flutterclient/assets/images/logo_small.png'
                              : 'assets/images/logo_small.png')
                      : MemoryImage(utf8.base64Decode(this
                          .appState
                          .files[this.appState.applicationStyle?.loginIcon])),
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
