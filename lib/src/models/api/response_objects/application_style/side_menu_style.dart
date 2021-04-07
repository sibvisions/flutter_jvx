import 'package:flutter/material.dart';
import 'package:flutterclient/src/util/color/color_extension.dart';

class SideMenuStyle {
  final Color? color;
  final Color? textColor;
  final Color? groupColor;
  final Color? selectionColor;

  SideMenuStyle(
      {this.color, this.textColor, this.groupColor, this.selectionColor});

  factory SideMenuStyle.fromJson(Map<String, dynamic> map) {
    Color? color;
    Color? textColor;
    Color? groupColor;
    Color? selectionColor;

    if (map['sidemenu'] != null) {
      color = map['sidemenu']['color'] != null
          ? HexColor.fromHex(map['sidemenu']['color'])
          : null;
      textColor = map['sidemenu']['textColor'] != null
          ? HexColor.fromHex(map['sidemenu']['textColor'])
          : null;
      groupColor = map['sidemenu']['groupColor'] != null
          ? HexColor.fromHex(map['sidemenu']['groupColor'])
          : null;
      selectionColor = map['sidemenu']['selectionColor'] != null
          ? HexColor.fromHex(map['sidemenu']['selectionColor'])
          : null;
    }

    return SideMenuStyle(
        color: color,
        textColor: textColor,
        groupColor: groupColor,
        selectionColor: selectionColor);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'sidemenu': {
          'color': color?.toHex(),
          'textColor': textColor?.toHex(),
          'groupColor': groupColor?.toHex(),
          'selectionColor': selectionColor?.toHex()
        }
      };
}
