abstract class ApiObjectProperty {
  //General Properties -- any Component can have these
  static const String id = "id";
  static const String name = "name";
  static const String className = "className";
  static const String constraints = "constraints";
  static const String parent = "parent";
  static const String indexOf = "indexOf";

  //Parent Properties -- any Component which can have children have these
  static const String layout = "layout";
  static const String layoutData = "layoutData";

  //Screen Properties -- only the most top Panel will have these
  static const String classNameEventSourceRef = "classNameEventSourceRef";
  static const String mobileAutoClose = "mobile.autoclose";
  static const String screenTitle = "screen_title_";
  static const String screenNavigationName = "screen_navigationName_";
  static const String screenModel = "screen_modal_";
  static const String screenClassName = "screen_className_";


  //Common Properties -- these may be used by many different Components
  static const String text = "text";
  static const String horizontalAlignment = "horizontalAlignment";
  static const String verticalAlignment = "verticalAlignment";




  //Can occur in both request & response
  static const String clientId = "clientId";
  static const String componentId = "componentId";

  //Request Properties
  static const String deviceMode = "deviceMode";
  static const String applicationName = "applicationName";
  static const String username = "username";
  static const String password = "password";
  static const String manualClose = "manualClose";
  static const String action = "action";
  static const String label = "label";


  //Response Properties
  static const String authenticated = "authenticated";
  static const String openScreen = "openScreen";
  static const String group = "group";
  static const String image = "image";
  static const String entries = "entries";
  static const String changedComponents = "changedComponents";

}