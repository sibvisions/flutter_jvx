import 'package:flutter/material.dart';
import 'package:flutterclient/src/util/color/color_extension.dart';

class DesktopStyle {
  final String? desktopIcon;
  final Color? desktopColor;

  DesktopStyle({this.desktopIcon, this.desktopColor});

  DesktopStyle.fromJson(Map<String, dynamic> map)
      : assert(map.isNotEmpty),
        desktopIcon = map['desktop.icon'],
        desktopColor = map['desktop.color'] != null
            ? HexColor.fromHex(map['desktop.color'])
            : null;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'desktop.icon': desktopIcon,
    'desktop.color': desktopColor?.toHex()
  };
}
