import 'package:flutter/material.dart';
import 'package:flutterclient/src/util/color/color_extension.dart';

class LoginStyle {
  final String? title;
  final Color? background;
  final String? infoText;
  final String? icon;
  final String? logo;

  LoginStyle(
      {this.title, this.background, this.infoText, this.icon, this.logo});

  LoginStyle.fromJson(Map<String, dynamic> map)
      : assert(map.isNotEmpty),
        background = map['login.background'] != null
            ? HexColor.fromHex(map['login.background'])
            : null,
        title = map['login.title'],
        icon = map['login.icon'],
        infoText = map['login.infoText'],
        logo = map['login.logo'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'login.background': background?.toHex(),
        'login.title': title,
        'login.icon': icon,
        'login.infoText': infoText,
        'login.logo': logo
      };
}
