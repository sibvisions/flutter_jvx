import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/auth_data.dart';
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
  bool loading = false;
  String message;
  String title;
  String details;
  List<ResponseObject> responseObjects;

  Response();

  Response.fromJson(List json) {
    if (json[0] != null && json[0]['title'] == 'Error') {
      error = true;
      message = json[0]['message'];
      title = json[0]['title'];
      details = json[0]['details'];
      return;
    }

    responseObjects = <ResponseObject>[];

    json.forEach((r) {
      switch (getResponseObjectTypeEnum(r['name'])) {
        case ResponseObjectType.APPLICATIONMETADATA:
          responseObjects.add(ApplicationMetaData.fromJson(r));
          break;
        case ResponseObjectType.LANGUAGE:
          responseObjects.add(Language.fromJson(r));
          break;
        case ResponseObjectType.LOGIN:
          responseObjects.add(LoginItem.fromJson(r));
          break;
        case ResponseObjectType.MENU:
          responseObjects.add(Menu.fromJson(r));
          break;
        case ResponseObjectType.AUTHENTICATIONDATA:
          responseObjects.add(AuthenticationData.fromJson(r));
          break;
        case ResponseObjectType.SCREEN_GENERIC:
          if (r['changedComponents'] != null)
            ScreenGeneric.fromChangedComponentsJson(r);
          else
            ScreenGeneric.fromUpdateComponentsJson(r);
          break;
        case ResponseObjectType.DAL_FETCH:
          // TODO: Handle this case.
          break;
        case ResponseObjectType.DAL_META_DATA:
          // TODO: Handle this case.
          break;
      }
    });
  }
}
