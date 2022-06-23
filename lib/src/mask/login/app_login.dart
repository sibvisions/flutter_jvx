import 'package:flutter/material.dart';
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
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: Container()),
        Expanded(
          flex: 8,
          child: Row(children: [
            Expanded(child: Container()),
            Expanded(
              flex: 8,
              child: SingleChildScrollView(child: loginCard),
            ),
            Expanded(child: Container())
          ]),
        ),
        Expanded(child: Container()),
      ]),
    ));
  }
}
