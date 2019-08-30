class ApplicationStyleResponse {
  String loginTitle;
  String loginBackground;
  String loginInfotext;
  String loginIcon;
  String desktopIcon;
  String menuMode;

  ApplicationStyleResponse();

  ApplicationStyleResponse.fromJson(Map<String, dynamic> json)
    : loginTitle = json['login.title'],
      loginBackground = json['login.background'],
      loginInfotext = json['login.infotext'],
      loginIcon = json['login.icon'],
      desktopIcon = json['desktop.icon'],
      menuMode = json['menu']['mode'];

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