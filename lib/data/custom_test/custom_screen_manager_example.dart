import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/custom/custom_screen_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../src/model/custom/custom_menu_item.dart';
import '../../src/model/custom/custom_screen.dart';

class CustomScreenManagerExample extends CustomScreenManager {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CustomScreen customScreen1 = CustomScreen(
    isOfflineScreen: true,
    screenName: "Fir-N7_CUSTOM",
    screenTitle: "Title THIS",
    menuItemModel: CustomMenuItem(
      screenId: "Fir-N7_CUSTOM",
      label: "CUSTOM FEATURE",
      group: "Features",
      icon: const FaIcon(FontAwesomeIcons.airbnb),
    ),
    screenFactory: () => const Text("asd"),
    footerFactory: () => SizedBox(
        height: 50,
        child: Container(
          color: Colors.black,
        )),
  );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CustomScreenManagerExample() {
    registerScreen(pCustomScreen: customScreen1);
  }
}
