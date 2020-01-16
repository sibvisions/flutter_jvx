import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/custom_screen/custom_screen_api.dart';
import 'package:jvx_mobile_v3/custom_screen/first_custom_screen.dart';

class FirstCustomScreenApi extends CustomScreenApi {  
  FirstCustomScreenApi();

  @override
  bool showCustomScreen() {
    return false;
  }

  @override
  Widget getWidget() {
    return FirstCustomScreenWidget();
  }

  @override
  onMenuButtonPressed(BuildContext context, String label, String group) {
    super.onMenuButtonPressed(context, label, group);
  }
}