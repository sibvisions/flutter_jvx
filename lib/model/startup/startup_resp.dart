import 'package:jvx_mobile_v3/model/application_meta_data.dart';
import 'package:jvx_mobile_v3/model/base_resp.dart';
import 'package:jvx_mobile_v3/model/language.dart';
import 'package:jvx_mobile_v3/model/login_item.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';

/// Model for the [Startup] response.
///
/// * [language]: Holds information about the language to use.
/// * [applicationMetaData]: Meta data about the application.
/// * [loginItem]: Information about the [LoginPage].
/// * [items]: If auto login is activated then the list holds the menu items shown in the [MenuPage].
class StartupResponse extends BaseResponse {
  String status;
  Language language;
  ApplicationMetaData applicationMetaData;
  LoginItem loginItem;
  List<MenuItem> items;

  StartupResponse({this.language, this.applicationMetaData, this.loginItem, this.status});

  StartupResponse.fromJson(List json) : super.fromJson(json) {
    if (isError)
      return;

    language = Language.fromJson(json[1]);
    applicationMetaData = ApplicationMetaData.fromJson(json[0]);
    if (json[2]['name'] == 'login') { loginItem = LoginItem.fromJson(json[2]); items = null; }
    else if (json[2]['name'] == 'menu') { items = readMenuItemListFromJson(json[2]['items']); loginItem = null; }
  }

  /// Method for reading and returning the [items] as a list.
  readMenuItemListFromJson(List items) {
    List<MenuItem> convertedMenuItems = new List<MenuItem>();
    for (int i = 0; i < items.length; i++) {
      convertedMenuItems.add(MenuItem.fromJson(items[i]));
    }
    return convertedMenuItems;
  }
}