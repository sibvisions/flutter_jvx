import 'package:flutter/material.dart';

import '../../../util/image/image_loader.dart';
import '../../../util/parse_util.dart';
import '../../mixin/config_service_mixin.dart';
import '../../mixin/ui_service_mixin.dart';
import 'arc_clipper.dart';

/// Login page of the app, also used for reset/change password
class AppLogin extends StatelessWidget with UiServiceMixin, ConfigServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The Widget displayed in the middle of the screen
  final Widget loginCard;

  Color? topColor;
  Color? bottomColor;
  Color? backgroundColor;
  String? loginLogo;
  String? loginBackground;
  bool inverseColor = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppLogin({Key? key, required this.loginCard}) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    loginBackground = configService.getAppStyle()?['login.icon'];
    loginLogo = configService.getAppStyle()?['login.logo'];

    backgroundColor = ParseUtil.parseHexColor(configService.getAppStyle()?['login.background']);
    inverseColor = ParseUtil.parseBool(configService.getAppStyle()?['login.inverseColor']) ?? false;

    if (inverseColor) {
      topColor = ParseUtil.parseHexColor(configService.getAppStyle()?['login.bottomColor']);
      bottomColor = ParseUtil.parseHexColor(configService.getAppStyle()?['login.topColor']);
    } else {
      topColor = ParseUtil.parseHexColor(configService.getAppStyle()?['login.topColor']);
      bottomColor = ParseUtil.parseHexColor(configService.getAppStyle()?['login.bottomColor']);
    }

    return (Scaffold(
      backgroundColor: bottomColor ?? Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipPath(
                  clipper: ArcClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: topColor ?? Theme.of(context).primaryColor,
                    ),
                    child: loginLogo != null ? ImageLoader.loadImage(loginLogo!, fit: BoxFit.scaleDown) : null,
                  ),
                ),
                flex: 4,
              ),
              Expanded(
                child: Container(
                  child: loginBackground != null ? ImageLoader.loadImage(loginBackground!, fit: BoxFit.fill) : null,
                  color: bottomColor ?? Colors.transparent,
                ),
                flex: 6,
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
    ));
  }
}
