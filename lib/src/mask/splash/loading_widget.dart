import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

import '../../../flutter_jvx.dart';
import '../../../util/image/image_loader.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: Svg(
                  ImageLoader.getAssetPath(
                    FlutterJVx.package,
                    'assets/images/JVx_Bg.svg',
                  ),
                ),
                fit: BoxFit.fill),
          ),
        ),
        Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Image(
                image: Svg(
                  ImageLoader.getAssetPath(
                    FlutterJVx.package,
                    'assets/images/JVx_SS.svg',
                  ),
                  size: const Size(138, 145),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                CircularProgressIndicator.adaptive(),
                Padding(padding: EdgeInsets.only(top: 50), child: Text('Loading...'))
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Image.asset(
                ImageLoader.getAssetPath(
                  FlutterJVx.package,
                  'assets/images/logo.png',
                ),
                width: 200,
              ),
            ),
          ),
        ])
      ],
    ));
  }
}
