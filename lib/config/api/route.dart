enum Method {
  DELETE,
  GET,
  HEAD,
  OPTIONS,
  POST,
  PUT,
  PATCH,
}

class Route {
  static const Route POST_STARTUP = Route(Method.POST, "api/v4/startup");
  static const Route POST_LOGIN = Route(Method.POST, "api/v2/login");
  static const Route POST_OPEN_SCREEN = Route(Method.POST, "api/v2/openScreen");
  static const Route POST_DEVICE_STATUS = Route(Method.POST, "api/deviceStatus");
  static const Route POST_PRESS_BUTTON = Route(Method.POST, "api/v2/pressButton");
  static const Route POST_SET_VALUE = Route(Method.POST, "api/comp/setValue");
  static const Route POST_SET_VALUES = Route(Method.POST, "api/dal/setValues");
  static const Route POST_CLOSE_TAB = Route(Method.POST, "api/comp/closeTab");
  static const Route POST_SELECT_TAB = Route(Method.POST, "api/comp/selectTab");
  static const Route POST_CHANGE_PASSWORD = Route(Method.POST, "api/changePassword");
  static const Route POST_RESET_PASSWORD = Route(Method.POST, "api/resetPassword");
  static const Route POST_NAVIGATION = Route(Method.POST, "api/navigation");
  static const Route POST_MENU = Route(Method.POST, "api/menu");
  static const Route POST_FETCH = Route(Method.POST, "api/dal/fetch");
  static const Route POST_LOGOUT = Route(Method.POST, "api/logout");
  static const Route POST_FILTER = Route(Method.POST, "api/dal/filter");
  static const Route POST_INSERT_RECORD = Route(Method.POST, "api/dal/insertRecord");
  static const Route POST_SELECT_RECORD = Route(Method.POST, "api/dal/selectRecord");
  static const Route POST_CLOSE_SCREEN = Route(Method.POST, "api/closeScreen");
  static const Route POST_DELETE_RECORD = Route(Method.POST, "api/dal/deleteRecord");
  static const Route POST_CLOSE_FRAME = Route(Method.POST, "api/closeFrame");
  static const Route POST_DOWNLOAD = Route(Method.POST, "download");
  static const Route POST_UPLOAD = Route(Method.POST, "upload");
  static const Route POST_CHANGES = Route(Method.POST, "api/changes");

  final String route;
  final Method method;

  const Route(this.method, this.route);

  @override
  String toString() {
    return "$method/$route";
  }
}
