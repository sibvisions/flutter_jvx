import 'package:equatable/equatable.dart';

enum RequestType {
  STARTUP,
  LOGIN,
  LOGOUT,
  OPEN_SCREEN,
  CLOSE_SCREEN,
  DOWNLOAD_TRANSLATION,
  DOWNLOAD_IMAGES,
  APP_STYLE,
  DAL_SELECT_RECORD,
  DAL_SET_VALUE,
  DAL_FETCH,
  PRESS_BUTTON,
  NAVIGATION
}

bool isScreenRequest(RequestType type) {
  return (type == RequestType.OPEN_SCREEN ||
    type == RequestType.DAL_FETCH ||
    type == RequestType.DAL_SELECT_RECORD ||
    type == RequestType.DAL_SET_VALUE ||
    type == RequestType.PRESS_BUTTON ||
    type == RequestType.CLOSE_SCREEN ||
    type == RequestType.NAVIGATION);
}

abstract class Request extends Equatable {
  RequestType requestType;
  String clientId;

  Request({this.requestType, this.clientId});

  Map<String, dynamic> toJson();
}
