import 'package:jvx_mobile_v3/model/api/exceptions/api_exception.dart';
import 'package:jvx_mobile_v3/model/api/exceptions/session_timeout_exception.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/application_style/application_style_resp.dart';
import 'package:jvx_mobile_v3/model/auth_data.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/data/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/model/login_item.dart';
import 'package:jvx_mobile_v3/model/menu.dart';
import 'package:jvx_mobile_v3/model/screen_generic.dart';

import '../../application_meta_data.dart';
import '../../language.dart';
import 'response_object.dart';

class Response {
  dynamic download;
  RequestType requestType;
  bool error;
  String errorName;
  bool loading = false;
  String message;
  String title;
  String details;
  ApplicationMetaData applicationMetaData;
  Language language;
  LoginItem loginItem;
  Menu menu;
  AuthenticationData authenticationData;
  ScreenGeneric screenGeneric;
  List<JVxData> jVxData = <JVxData>[];
  List<JVxMetaData> jVxMetaData = <JVxMetaData>[];
  ApplicationStyleResponse applicationStyle;

  Response();

  Response.fromJsonForAppStyle(Map<String, dynamic> json) {
    checkForError(json);
    error = false;
    applicationStyle = ApplicationStyleResponse.fromJson(json);
  }

  static checkForError(Map<String, dynamic> json) {
    if (json != null && json['title'] == 'Error') {
      if (json['name'] == 'message.sessionexpired')
        throw new SessionExpiredException(
            details: json['details'], title: json['title'], name: json['name']);
      else
        throw new ApiException(
            details: json['details'], title: json['title'], name: json['name']);
    }
  }

  Response.fromJson(List json) {
    checkForError(json[0]);

    error = false;

    json.forEach((r) {
      switch (getResponseObjectTypeEnum(r['name'])) {
        case ResponseObjectType.APPLICATIONMETADATA:
          applicationMetaData = ApplicationMetaData.fromJson(r);
          break;
        case ResponseObjectType.LANGUAGE:
          language = Language.fromJson(r);
          break;
        case ResponseObjectType.LOGIN:
          loginItem = LoginItem.fromJson(r);
          break;
        case ResponseObjectType.MENU:
          menu = Menu.fromJson(r);
          break;
        case ResponseObjectType.AUTHENTICATIONDATA:
          authenticationData = AuthenticationData.fromJson(r);
          break;
        case ResponseObjectType.SCREEN_GENERIC:
          if (r['changedComponents'] != null)
            screenGeneric = ScreenGeneric.fromChangedComponentsJson(r);
          else
            screenGeneric = ScreenGeneric.fromUpdateComponentsJson(r);
          break;
        case ResponseObjectType.DAL_FETCH:
          jVxData.add(JVxData.fromJson(r));
          break;
        case ResponseObjectType.DAL_META_DATA:
          jVxMetaData.add(JVxMetaData.fromJson(r));
          break;
      }
    });
  }
}
