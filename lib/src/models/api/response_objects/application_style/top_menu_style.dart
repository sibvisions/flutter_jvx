import 'package:flutter/material.dart';
import 'package:flutterclient/src/util/color/color_extension.dart';

class TopMenuStyle {
  final Color? color;
  final Color? iconColor;
  final String? logo;

  TopMenuStyle({this.color, this.iconColor, this.logo});

  factory TopMenuStyle.fromJson(Map<String, dynamic> map) {
    Color? color;
    Color? iconColor;
    String? logo;

    if (map['topmenu'] != null) {
      color = map['topmenu']['color'] != null
          ? HexColor.fromHex(map['topmenu']['color'])
          : null;
      iconColor = map['topmenu']['iconColor'] != null
          ? HexColor.fromHex(map['topmenu']['iconColor'])
          : null;
      logo = map['topmenu']['topmenulogo'];
    }

    return TopMenuStyle(
      color: color,
      iconColor: iconColor,
      logo: logo,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'topmenu': {
          'color': color?.toHex(),
          'iconColor': iconColor?.toHex(),
          'topmenulogo': logo
        }
      };
}
