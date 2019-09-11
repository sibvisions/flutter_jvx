import 'package:jvx_mobile_v3/model/base_resp.dart';

class ApplicationStyleResponse extends BaseResponse {
  String loginTitle;
  String loginBackground;
  String loginInfotext;
  String loginIcon;
  String desktopIcon;
  String menuMode;

  ApplicationStyleResponse();

  ApplicationStyleResponse.fromJson(Map<String, dynamic> json) : super.fromJson([json]) {
    loginTitle = json['login.title'];
    loginBackground = json['login.background'];
    loginInfotext = json['login.infotext'];
    loginIcon = json['login.icon'];
    desktopIcon = json['desktop.icon'];
    menuMode = json['menu']['mode'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'login.title': loginTitle,
    'login.background': loginBackground,
    'login.infotext': loginInfotext,
    'login.icon': loginIcon,
    'desktop.icon': desktopIcon,
    'menu': {
      'mode': menuMode
    }
  };
}