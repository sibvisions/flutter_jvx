import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../src/model/custom/custom_menu_item.dart';
import '../../src/model/custom/custom_screen.dart';
import '../../src/model/custom/custom_screen_manager.dart';

class CustomScreenManagerExample extends CustomScreenManager {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CustomScreenManagerExample() {
    registerScreen(
        pCustomScreen: CustomScreen(
      isOfflineScreen: true,
      screenName: "Fir-N7_CUSTOM",
      screenTitle: "Title THIS",
      menuItemModel: CustomMenuItem(
        screenId: "Fir-N7_CUSTOM",
        label: "CUSTOM FEATURE",
        group: "Features",
        icon: const FaIcon(FontAwesomeIcons.airbnb),
      ),
      screenFactory: (context) => Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text("Example Label"),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  const snackBar = SnackBar(
                    content: Text("Yay! A SnackBar!"),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: const Text("Example Button"),
              ),
            ),
          ),
        ],
      ),
      footerFactory: (context) => SizedBox(
          height: 50,
          child: Container(
            color: Colors.blue,
          )),
    ));
  }
}
