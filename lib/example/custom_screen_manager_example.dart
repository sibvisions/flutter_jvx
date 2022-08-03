import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../custom/custom_menu_item.dart';
import '../custom/custom_screen.dart';
import '../custom/custom_screen_manager.dart';
import 'custom_header_example.dart';

class CustomScreenManagerExample extends CustomScreenManager {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CustomScreenManagerExample() {
    registerScreen(CustomScreen(
      showOffline: true,
      screenTitle: "Title THIS",
      menuItemModel: CustomMenuItem(
        screenLongName: "Fir-N7_CUSTOM",
        label: "CUSTOM FEATURE",
        group: "Features",
        icon: const FaIcon(FontAwesomeIcons.airbnb),
      ),
      headerBuilder: (context) => const CustomHeaderExample(),
      screenBuilder: (context) => Column(
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
      footerBuilder: (context) => SizedBox(
          height: 50,
          child: Container(
            color: Colors.blue,
          )),
    ));
  }
}