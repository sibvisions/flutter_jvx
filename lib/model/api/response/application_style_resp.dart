import 'dart:convert';

import 'package:crypto/crypto.dart';
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
  String hash;
  double controlsOpacity = 1.0;
  double menuOpacity = 1.0;
  double sidemenuOpacity = 1.0;

  ApplicationStyleResponse();

  ApplicationStyleResponse.fromJson(Map<String, dynamic> jsonMap) {
    loginTitle = jsonMap['login.title'];
    loginInfotext = jsonMap['login.infotext'];
    loginIcon = jsonMap['login.icon'];
    loginLogo = jsonMap['login.logo'];
    desktopIcon = jsonMap['desktop.icon'];
    if (jsonMap['menu'] != null)
      menuMode = jsonMap['menu']['mode'];
    else
      menuMode = null;

    if (jsonMap['theme'] != null &&
        HexColor.isHexColor(jsonMap['theme']['color']))
      themeColor = HexColor(jsonMap['theme']['color']);
    else
      themeColor = null;

    if (jsonMap['desktop.color'] != null &&
        HexColor.isHexColor(jsonMap['desktop.color']))
      desktopColor = HexColor(jsonMap['desktop.color']);
    else
      desktopColor = null;

    if (jsonMap['login.background'] != null &&
        HexColor.isHexColor(jsonMap['login.background']))
      loginBackground = HexColor(jsonMap['login.background']);
    else
      loginBackground = null;

    if (jsonMap['opacity'] != null) {
      menuOpacity = jsonMap['opacity']['menu'] != null
          ? double.tryParse(jsonMap['opacity']['menu'])
          : null;
      if (menuOpacity == null || menuOpacity < 0 || menuOpacity > 1)
        menuOpacity = 1.0;

      sidemenuOpacity = jsonMap['opacity']['sidemenu'] != null
          ? double.tryParse(jsonMap['opacity']['sidemenu'])
          : null;
      if (sidemenuOpacity == null) sidemenuOpacity = 1.0;

      controlsOpacity = jsonMap['opacity']['controls'] != null
          ? double.tryParse(jsonMap['opacity']['controls'])
          : null;
      if (controlsOpacity == null) controlsOpacity = 1.0;
    }

    String jsonStr = json.encode(jsonMap);
    var bytes = utf8.encode(jsonStr);
    hash = sha256.convert(bytes).toString();
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'login.title': loginTitle,
        'login.infotext': loginInfotext,
        'login.icon': loginIcon,
        'login.logo': loginLogo,
        'desktop.icon': desktopIcon,
        'menu': {'mode': menuMode},
        'theme': {'color': themeColor.value},
        'desktop.color': desktopColor,
        'login.background': loginBackground
      };
}
