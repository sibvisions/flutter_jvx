import 'package:jvx_mobile_v3/model/action.dart';
import 'package:jvx_mobile_v3/model/api/exceptions/api_exception.dart';
import 'package:jvx_mobile_v3/model/api/exceptions/session_timeout_exception.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/application_style_resp.dart';
import 'package:jvx_mobile_v3/model/api/response/auth_data.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/api/response/download_action.dart';
import 'package:jvx_mobile_v3/model/api/response/login_item.dart';
import 'package:jvx_mobile_v3/model/api/response/menu.dart';
import 'package:jvx_mobile_v3/model/api/response/screen_generic.dart';
import 'package:jvx_mobile_v3/model/api/response/upload_action.dart';

import 'application_meta_data.dart';
import 'language.dart';
import 'meta_data/jvx_meta_data.dart';
import 'response_object.dart';

class Response {
  dynamic download;
  String downloadFileName;
  RequestType requestType;
  bool error;
  String errorName;
  bool loading = false;
  String message;
  String title;
  Action action;
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
  DownloadAction downloadAction;
  UploadAction uploadAction;
  Request request;

  Response();

  Response.fromJsonForAppStyle(Map<String, dynamic> json) {
    checkForError(json);
    error = false;
    if (json != null)
      applicationStyle = ApplicationStyleResponse.fromJson(json);
    else
      applicationStyle = null;
  }

  static checkForError(Map<String, dynamic> json) {
    if (json != null && (json['title'] == 'Error' || json['title'] == 'Session Expired')) {
      throw new ApiException(
          details: json['details'], title: json['title'], name: json['name'], message: json['message']);
    }
  }

  Response.fromJson(List json) {
    if (json.isNotEmpty) {
      json.forEach((e) => checkForError(e));
    }

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
        case ResponseObjectType.DOWNLOAD:
          downloadAction = DownloadAction.fromJson(r);
          break;
        case ResponseObjectType.UPLOAD:
          uploadAction = UploadAction.fromJson(r);
          break;
      }
    });
  }
}
