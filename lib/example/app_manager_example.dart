import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../flutter_jvx.dart';
import 'custom_header_example.dart';

class AppManagerExample extends AppManager {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppManagerExample() {
    registerScreen(CustomScreen(
      screenLongName: "Fir-N7_CUSTOM",
      showOffline: true,
      screenTitle: "Custom Title",
      menuItemModel: CustomMenuItem(
        screenLongName: "Fir-N7_CUSTOM",
        label: "Custom Screen",
        group: "Features",
        faIcon: FontAwesomeIcons.airbnb,
      ),
      headerBuilder: (context) => const CustomHeaderExample(),
      screenBuilder: (context, screen) => Column(
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
