import 'package:flutter/material.dart';

import '../../../services.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/parse_util.dart';
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
    String? loginIcon = IConfigService().getAppStyle()['login.icon'];
    String? loginLogo = IConfigService().getAppStyle()['login.logo'];

    //Color? backgroundColor = ParseUtil.parseHexColor(IConfigService().getAppStyle()?['login.background']);
    bool inverseColor = ParseUtil.parseBool(IConfigService().getAppStyle()['login.inverseColor']) ?? false;

    Color? topColor = ParseUtil.parseHexColor(IConfigService().getAppStyle()['login.topColor']);
    Color? bottomColor = ParseUtil.parseHexColor(IConfigService().getAppStyle()['login.bottomColor']);

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
                    child: loginLogo != null ? ImageLoader.loadImage(loginLogo, pFit: BoxFit.scaleDown) : null,
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Container(
                  color: bottomColor ?? Colors.transparent,
                  child: loginIcon != null ? ImageLoader.loadImage(loginIcon, pFit: BoxFit.fitWidth) : null,
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
