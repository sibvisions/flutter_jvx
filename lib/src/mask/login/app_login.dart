import 'package:flutter/material.dart';
import 'package:flutter_client/main.dart';
import 'package:flutter_client/src/mask/login/arc_clipper.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';

/// Login page of the app, also used for reset/change password
class AppLogin extends StatelessWidget with UiServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The Widget displayed in the middle of the screen
  final Widget loginCard;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppLogin({Key? key, required this.loginCard}) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    // uiService.setRouteContext(pContext: context);
    return (Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(children: [
        Expanded(
          child: ClipPath(
            clipper: ArcClipper(),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: themeData.backgroundColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.fitHeight),
                  ),
                )
              ],
            ),
          ),
          flex: 4,
        ),
        Expanded(
          flex: 6,
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: Container()),
            Expanded(
              flex: 8,
              child: SingleChildScrollView(child: loginCard),
            ),
            Expanded(child: Container())
          ]),
        ),
        Expanded(
          child: Container(),
          flex: 1,
        ),
      ]),
    ));
  }
}
