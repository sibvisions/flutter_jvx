import 'dart:convert';

import 'package:jvx_mobile_v3/model/auth_data.dart';
import 'package:jvx_mobile_v3/model/base_resp.dart';
import 'package:jvx_mobile_v3/model/language.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';

class CreateLoginResponse extends BaseResponse {
  String status;
  CreateLoginResponse({this.status});

  CreateLoginResponse.fromJson(Map<String, dynamic> json) : super.fromJson([json]) { 
    status = json['status'];
  }
}

class LoginResponse extends BaseResponse {
  Language language;
  List<MenuItem> items;
  String componentId;
  AuthenticationData authenticationData;

  LoginResponse({this.language, this.items, this.componentId, String name, this.authenticationData}) {
    super.name = name;
  }

  LoginResponse.fromJson(List jsonData) : super.fromLoginJson(jsonData){
    if (isError || isSessionExpired)
      return;

    language = Language.fromJson(jsonData[0]);
    authenticationData = AuthenticationData.fromJson(jsonData[1]);
    items = readMenuItemListFromJson(jsonData[2]['items']);
    name = jsonData[2]['name'];
    componentId = jsonData[2]['componentId'];
  }

  LoginResponse.fromJsonWithoutKey(List jsonData) : super.fromLoginJson(jsonData) {
    if (isError || isSessionExpired)
      return;

    language = Language.fromJson(jsonData[0]);
    items = readMenuItemListFromJson(jsonData[1]['items']);
    name = jsonData[1]['name'];
    componentId = jsonData[1]['componentId'];
  }

  static readMenuItemListFromJson(List items) {
    List<MenuItem> convertedMenuItems = new List<MenuItem>();
    try {
      for (int i = 0; i < items.length; i++) {
        convertedMenuItems.add(MenuItem.fromJson(items[i]));
      }
    } catch (e) {
      print(e.toString());
    }
    return convertedMenuItems;
  }
}
