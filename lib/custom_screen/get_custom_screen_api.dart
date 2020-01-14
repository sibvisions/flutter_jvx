import 'package:jvx_mobile_v3/custom_screen/custom_screen_api.dart';
import 'package:jvx_mobile_v3/custom_screen/first_custom_screen_api.dart';

/// Devs need to return their CustomScreenAPI Instance here
/// 
/// This Method will be called from the Menu
CustomScreenApi getCustomScreenAPI() {
  return FirstCustomScreenApi();
}