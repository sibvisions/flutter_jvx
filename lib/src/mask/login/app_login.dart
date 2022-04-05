import 'package:flutter/material.dart';

/// Login page of the app, also used for reset/change password
class AppLogin extends StatelessWidget {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The Widget displayed in the middle of the screen
  final Widget loginCard;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppLogin({
    Key? key,
    required this.loginCard
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Row(children: [
        Expanded(child: Container()),
        Expanded(
          flex: 8,
          child: SingleChildScrollView(
            child: loginCard
          ),
        ),
        Expanded(child: Container())
      ]),
    ));
  }
}
