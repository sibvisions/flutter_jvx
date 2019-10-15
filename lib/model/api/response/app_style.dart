import 'dart:convert';

import 'package:jvx_mobile_v3/model/api/response/response_object.dart';

class AppStyle extends ResponseObject {
  String loginTitle;
  String loginBackground;
  String loginInfotext;
  String loginIcon;
  String desktopIcon;
  String menuMode;
  
  AppStyle({
    this.loginTitle,
    this.loginBackground,
    this.loginInfotext,
    this.loginIcon,
    this.desktopIcon,
    this.menuMode,
  });

  AppStyle copyWith({
    String loginTitle,
    String loginBackground,
    String loginInfotext,
    String loginIcon,
    String desktopIcon,
    String menuMode,
  }) {
    return AppStyle(
      loginTitle: loginTitle ?? this.loginTitle,
      loginBackground: loginBackground ?? this.loginBackground,
      loginInfotext: loginInfotext ?? this.loginInfotext,
      loginIcon: loginIcon ?? this.loginIcon,
      desktopIcon: desktopIcon ?? this.desktopIcon,
      menuMode: menuMode ?? this.menuMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loginTitle': loginTitle,
      'loginBackground': loginBackground,
      'loginInfotext': loginInfotext,
      'loginIcon': loginIcon,
      'desktopIcon': desktopIcon,
      'menuMode': menuMode,
    };
  }

  static AppStyle fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return AppStyle(
      loginTitle: map['loginTitle'],
      loginBackground: map['loginBackground'],
      loginInfotext: map['loginInfotext'],
      loginIcon: map['loginIcon'],
      desktopIcon: map['desktopIcon'],
      menuMode: map['menuMode'],
    );
  }

  String toJson() => json.encode(toMap());

  static AppStyle fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'AppStyle loginTitle: $loginTitle, loginBackground: $loginBackground, loginInfotext: $loginInfotext, loginIcon: $loginIcon, desktopIcon: $desktopIcon, menuMode: $menuMode';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is AppStyle &&
      o.loginTitle == loginTitle &&
      o.loginBackground == loginBackground &&
      o.loginInfotext == loginInfotext &&
      o.loginIcon == loginIcon &&
      o.desktopIcon == desktopIcon &&
      o.menuMode == menuMode;
  }

  @override
  int get hashCode {
    return loginTitle.hashCode ^
      loginBackground.hashCode ^
      loginInfotext.hashCode ^
      loginIcon.hashCode ^
      desktopIcon.hashCode ^
      menuMode.hashCode;
  }
}