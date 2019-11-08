import 'package:jvx_mobile_v3/model/api/response/response_object.dart';

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
  String loginBackground;
  String loginInfotext;
  String loginIcon;
  String desktopIcon;
  String menuMode;

  ApplicationStyleResponse();

  ApplicationStyleResponse.fromJson(Map<String, dynamic> json) {
    loginTitle = json['login.title'];
    loginBackground = json['login.background'];
    loginInfotext = json['login.infotext'];
    loginIcon = json['login.icon'];
    desktopIcon = json['desktop.icon'];
    if (json['menu'] != null)
      menuMode = json['menu']['mode'];
    else
      menuMode = null;
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