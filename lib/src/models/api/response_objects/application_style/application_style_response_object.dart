import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutterclient/src/util/color/color_extension.dart';

import '../../response_object.dart';
import 'desktop_style.dart';
import 'login_style.dart';
import 'opacity_style.dart';
import 'side_menu_style.dart';
import 'top_menu_style.dart';

class ApplicationStyleResponseObject extends ResponseObject {
  final String? menuMode;
  final String? hash;
  final Color? themeColor;
  final LoginStyle? loginStyle;
  final DesktopStyle? desktopStyle;
  final OpacityStyle? opacity;
  final SideMenuStyle? sideMenuStyle;
  final TopMenuStyle? topMenuStyle;

  final double cornerRadiusButtons = 5.0;
  final double cornerRadiusEditors = 5.0;
  final double cornerRadiusContainer = 5.0;
  final double cornerRadiusMenu = 15.0;

  double textScaleFactor = 1.0;

  ShapeBorder get buttonShape {
    return RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(cornerRadiusButtons)));
  }

  ShapeBorder get containerShape {
    return RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(cornerRadiusContainer)));
  }

  ShapeBorder get editorsShape {
    return RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(cornerRadiusEditors)));
  }

  ShapeBorder get menuShape {
    return RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(cornerRadiusMenu)));
  }

  double get controlsOpacity {
    return opacity?.controlsOpacity ?? 1.0;
  }

  double get menuOpacity {
    return opacity?.menuOpacity ?? 1.0;
  }

  double get sideMenuOpacity {
    return opacity?.sideMenuOpacity ?? 1.0;
  }

  ApplicationStyleResponseObject({
    required String name,
    this.hash,
    this.menuMode,
    this.themeColor,
    this.loginStyle,
    this.desktopStyle,
    this.opacity,
    this.sideMenuStyle,
    this.topMenuStyle,
  }) : super(name: name);

  factory ApplicationStyleResponseObject.fromJson(
      {required Map<String, dynamic> map}) {
    String? menuMode;

    if (map['menu'] != null) {
      menuMode = map['menu']['mode'];
    }

    Color? themeColor;

    if (map['theme'] != null && map['theme']['color'] != null)
      themeColor = HexColor.fromHex(map['theme']['color']);

    final loginStyle = LoginStyle.fromJson(map);
    final desktopStyle = DesktopStyle.fromJson(map);

    SideMenuStyle? sideMenuStyle;

    if (map['theme'] != null &&
        map['theme']['web'] != null &&
        map['theme']['web']['sidemenu'] != null) {
      sideMenuStyle = SideMenuStyle.fromJson(map['theme']['web']);
    } else if (map['web'] != null && map['web']['sidemenu'] != null) {
      sideMenuStyle = SideMenuStyle.fromJson(map['web']);
    }

    TopMenuStyle? topMenuStyle;

    if (map['theme'] != null &&
        map['theme']['web'] != null &&
        map['theme']['web']['topmenu'] != null) {
      topMenuStyle = TopMenuStyle.fromJson(map);
    } else if (map['web'] != null && map['web']['topmenu'] != null) {
      topMenuStyle = TopMenuStyle.fromJson(map['web']);
    }

    OpacityStyle? opacityStyle;

    if (map['opacity'] != null) {
      opacityStyle = OpacityStyle.fromJson(map['opacity']);
    }

    String jsonStr = json.encode(map);
    var bytes = utf8.encode(jsonStr);
    final hash = sha256.convert(bytes).toString();

    return ApplicationStyleResponseObject(
        hash: hash,
        loginStyle: loginStyle,
        desktopStyle: desktopStyle,
        opacity: opacityStyle,
        sideMenuStyle: sideMenuStyle,
        topMenuStyle: topMenuStyle,
        menuMode: menuMode,
        themeColor: themeColor,
        name: 'applicationStyle');
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'menu': {'mode': menuMode},
        'theme': {
          'color': themeColor?.toHex(),
          if (sideMenuStyle != null) ...sideMenuStyle!.toJson(),
          if (topMenuStyle != null) ...topMenuStyle!.toJson()
        },
        'opacity': opacity?.toJson(),
        if (loginStyle != null) ...loginStyle!.toJson(),
        if (desktopStyle != null) ...desktopStyle!.toJson(),
      };
}
