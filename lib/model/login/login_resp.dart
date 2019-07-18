import 'package:jvx_mobile_v3/model/language.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';

class CreateLoginResponse {
  String status;
  CreateLoginResponse({this.status});

  CreateLoginResponse.fromJson(Map<String, dynamic> json)
    : status = json['status'];
}

class LoginResponse {
  Language language;
  List<MenuItem> items;
  String name;
  String componentId;

  LoginResponse({this.language, this.items});

  LoginResponse.fromJson(List jsonData)
    : language = Language.fromJson(jsonData[0]),
      items = readMenuItemListFromJson(jsonData[1]['items']),
      name = jsonData[1]['name'],
      componentId = jsonData[1]['componentId'];

  static readMenuItemListFromJson(List items) {
    List<MenuItem> convertedMenuItems = new List<MenuItem>();
    for (int i = 0; i < items.length; i++) {
      convertedMenuItems.add(MenuItem.fromJson(items[i]));
    }
    return convertedMenuItems;
  }
}
