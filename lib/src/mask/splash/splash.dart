import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

import '../../flutter_jvx.dart';
import '../../util/image/image_loader.dart';
import 'jvx_splash.dart';

class Splash extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final Widget Function(BuildContext context, AsyncSnapshot? snapshot)? loadingBuilder;
  final AsyncSnapshot? snapshot;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const Splash({
    super.key,
    this.loadingBuilder,
    this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    return loadingBuilder?.call(context, snapshot) ??
        JVxSplash(
          snapshot: snapshot,
          logo: Image(
            image: Svg(
              ImageLoader.getAssetPath(
                FlutterJVx.package,
                "assets/images/J.svg",
              ),
              size: const Size(138, 145),
            ),
          ),
          background: Svg(
            ImageLoader.getAssetPath(
              FlutterJVx.package,
              "assets/images/JVx_Bg.svg",
            ),
          ),
          branding: Image.asset(
            ImageLoader.getAssetPath(
              FlutterJVx.package,
              "assets/images/logo.png",
            ),
            width: 200,
          ),
        );
  }
}
