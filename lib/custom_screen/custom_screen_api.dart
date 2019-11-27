import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/custom_screen/first_custom_screen.dart';
import 'package:jvx_mobile_v3/custom_screen/i_custom_screen_api.dart';

class CustomScreenApi implements ICustomScreenApi {
  
  @override
  Widget getWidget() {
    // Change to your Custom Screen.
    return FirstCustomScreen();
  }

  @override
  bool showCustomScreen() {
    return false;
  }
}
