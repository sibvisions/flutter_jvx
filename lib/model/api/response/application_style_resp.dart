import 'package:flutter/material.dart';
import '../../../model/api/response/response_object.dart';
import '../../../model/properties/hex_color.dart';

/// Response from the [ApplicationStyle] Request.
/// 
/// [ApplicationStyle] is for the overall styling of the app.
/// 
/// * [loginTitle]: Text which will be show on [LoginPage] and in the [MenuDrawerWidget].
/// 
/// * [loginBackground]: Color or Image which is the background of the [LoginPage].
/// 
/// * [loginInfotext]: Text which is also shown on the [LoginPage].
/// 
/// * [loginIcon]: Image or Icon which will be shown in the top center of the [LoginPage].
/// 
/// * [menuMode]: Layout of the [MenuPage].
/// 
/// There are 3 possible [menuMode]'s:
/// 
///  * `grid`: Shows the [MenuGridView].
///  * `list`: Shows the [MenuListWidget].
///  * `drawer`: Shows the [MenuItem]'s in the [MenuDrawerWidget].
class ApplicationStyleResponse extends ResponseObject {
  String loginTitle;
  Color loginBackground;
  String loginInfotext;
  String loginIcon;
  String loginLogo;
  String desktopIcon;
  Color desktopColor;
  String menuMode;
  Color themeColor;

  ApplicationStyleResponse();

  ApplicationStyleResponse.fromJson(Map<String, dynamic> json) {
    loginTitle = json['login.title'];
    loginInfotext = json['login.infotext'];
    loginIcon = json['login.icon'];
    loginLogo = json['login.logo'];
    desktopIcon = json['desktop.icon'];
    if (json['menu'] != null)
      menuMode = json['menu']['mode'];
    else
      menuMode = null;

    if (json['theme'] != null && HexColor.isHexColor(json['theme']['color']))
      themeColor = HexColor(json['theme']['color']);
    else
      themeColor = null;

    if (json['desktop.color'] != null && HexColor.isHexColor(json['desktop.color']))
      desktopColor = HexColor(json['desktop.color']);
    else
      desktopColor = null;

    if (json['login.background'] != null && HexColor.isHexColor(json['login.background']))
      loginBackground = HexColor(json['login.background']);
    else
      loginBackground = null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'login.title': loginTitle,
    'login.background': loginBackground,
    'login.infotext': loginInfotext,
    'login.icon': loginIcon,
    'login.logo': loginLogo,
    'desktop.icon': desktopIcon,
    'menu': {
      'mode': menuMode
    },
    'theme': {
      'color': themeColor.value
    }
  };
}