import 'package:flutter/material.dart';
import 'package:flutter_client/main.dart';
import 'package:flutter_client/src/mask/login/arc_clipper.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/util/image/image_loader.dart';
import 'package:flutter_client/util/parse_util.dart';

/// Login page of the app, also used for reset/change password
class AppLogin extends StatelessWidget with UiServiceMixin, ConfigServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The Widget displayed in the middle of the screen
  final Widget loginCard;

  Color? topColor;
  Color? botColor;
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
      topColor = ParseUtil.parseHexColor(configService.getAppStyle()?['login.botColor']);
      botColor = ParseUtil.parseHexColor(configService.getAppStyle()?['login.topColor']);
    } else {
      topColor = ParseUtil.parseHexColor(configService.getAppStyle()?['login.topColor']);
      botColor = ParseUtil.parseHexColor(configService.getAppStyle()?['login.botColor']);
    }

    return (Scaffold(
      backgroundColor: botColor ?? Colors.white,
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
                      color: topColor ?? themeData.primaryColor,
                    ),
                    child: loginLogo != null ? ImageLoader.loadImage(loginLogo!, fit: BoxFit.contain) : null,
                  ),
                ),
                flex: 4,
              ),
              Expanded(
                child: Container(
                  child: loginBackground != null ? ImageLoader.loadImage(loginBackground!, fit: BoxFit.none) : null,
                  color: botColor ?? Colors.transparent,
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
