enum Method {
  DELETE,
  GET,
  HEAD,
  OPTIONS,
  POST,
  PUT,
  PATCH,
}

class APIRoute {
  static const APIRoute POST_STARTUP = APIRoute(Method.POST, "api/v4/startup");
  static const APIRoute POST_LOGIN = APIRoute(Method.POST, "api/v2/login");
  static const APIRoute POST_OPEN_SCREEN = APIRoute(Method.POST, "api/v2/openScreen");
  static const APIRoute POST_DEVICE_STATUS = APIRoute(Method.POST, "api/deviceStatus");
  static const APIRoute POST_PRESS_BUTTON = APIRoute(Method.POST, "api/v2/pressButton");
  static const APIRoute POST_SET_VALUE = APIRoute(Method.POST, "api/comp/setValue");
  static const APIRoute POST_SET_VALUES = APIRoute(Method.POST, "api/dal/setValues");
  static const APIRoute POST_CLOSE_TAB = APIRoute(Method.POST, "api/comp/closeTab");
  static const APIRoute POST_SELECT_TAB = APIRoute(Method.POST, "api/comp/selectTab");
  static const APIRoute POST_CHANGE_PASSWORD = APIRoute(Method.POST, "api/changePassword");
  static const APIRoute POST_RESET_PASSWORD = APIRoute(Method.POST, "api/resetPassword");
  static const APIRoute POST_NAVIGATION = APIRoute(Method.POST, "api/navigation");
  static const APIRoute POST_MENU = APIRoute(Method.POST, "api/menu");
  static const APIRoute POST_FETCH = APIRoute(Method.POST, "api/dal/fetch");
  static const APIRoute POST_LOGOUT = APIRoute(Method.POST, "api/logout");
  static const APIRoute POST_FILTER = APIRoute(Method.POST, "api/dal/filter");
  static const APIRoute POST_INSERT_RECORD = APIRoute(Method.POST, "api/dal/insertRecord");
  static const APIRoute POST_SELECT_RECORD = APIRoute(Method.POST, "api/dal/selectRecord");
  static const APIRoute POST_CLOSE_SCREEN = APIRoute(Method.POST, "api/closeScreen");
  static const APIRoute POST_DELETE_RECORD = APIRoute(Method.POST, "api/dal/deleteRecord");
  static const APIRoute POST_CLOSE_FRAME = APIRoute(Method.POST, "api/closeFrame");
  static const APIRoute POST_DOWNLOAD = APIRoute(Method.POST, "download");
  static const APIRoute POST_UPLOAD = APIRoute(Method.POST, "upload");
  static const APIRoute POST_CHANGES = APIRoute(Method.POST, "api/changes");
  static const APIRoute POST_MOUSE_CLICKED = APIRoute(Method.POST, "api/mouseClicked");
  static const APIRoute POST_MOUSE_PRESSED = APIRoute(Method.POST, "api/mousePressed");
  static const APIRoute POST_MOUSE_RELEASED = APIRoute(Method.POST, "api/mouseReleased");
  static const APIRoute POST_FOCUS_GAINED = APIRoute(Method.POST, "api/focusGained");
  static const APIRoute POST_FOCUS_LOST = APIRoute(Method.POST, "api/focusLost");

  final String route;
  final Method method;

  const APIRoute(this.method, this.route);

  @override
  String toString() {
    return "$method/$route";
  }
}
