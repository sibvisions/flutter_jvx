import 'package:flutter/material.dart';

import '../../../flutter_jvx.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/parse_util.dart';
import '../state/app_style.dart';
import 'arc_clipper.dart';

/// Login page of the app, also used for reset/change password
class AppLogin extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The Widget displayed in the middle of the screen
  final Widget loginCard;

  const AppLogin({Key? key, required this.loginCard}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appStyle = AppStyle.of(context)!.applicationStyle!;
    String? loginLogo = appStyle['login.logo'];

    bool inverseColor = ParseUtil.parseBool(appStyle['login.inverseColor']) ?? false;

    Color? topColor = ParseUtil.parseHexColor(appStyle['login.topColor']) ??
        ParseUtil.parseHexColor(appStyle['login.background']) ??
        Theme.of(context).colorScheme.primary;
    Color? bottomColor = ParseUtil.parseHexColor(appStyle['login.bottomColor']);

    if (inverseColor) {
      var tempTop = topColor;
      topColor = bottomColor;
      bottomColor = tempTop;
    }

    return Scaffold(
      backgroundColor: bottomColor ?? Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: ClipPath(
                  clipper: ArcClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: topColor ?? Colors.white,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Center(
                      child: loginLogo != null
                          ? ImageLoader.loadImage(loginLogo, pFit: BoxFit.scaleDown)
                          : Image.asset(
                              ImageLoader.getAssetPath(
                                FlutterJVx.package,
                                "assets/images/branding_sib_visions.png",
                              ),
                              fit: BoxFit.scaleDown,
                            ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: ColoredBox(
                  color: bottomColor ?? Colors.white,
                ),
              ),
            ],
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 10 * 8,
              child: SingleChildScrollView(child: loginCard),
            ),
          ),
        ],
      ),
    );
  }
}
