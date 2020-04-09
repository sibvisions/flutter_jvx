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
  DAL_DELETE,
  DAL_FILTER,
  DAL_INSERT,
  DAL_SAVE,
  DAL_METADATA,
  PRESS_BUTTON,
  NAVIGATION,
  LOADING,
  RELOAD,
  DEVICE_STATUS,
  DOWNLOAD,
  UPLOAD,
  CHANGE,
  SET_VALUE
}

bool isScreenRequest(RequestType type) {
  return (type == RequestType.OPEN_SCREEN ||
    type == RequestType.DAL_FETCH ||
    type == RequestType.DAL_SELECT_RECORD ||
    type == RequestType.DAL_SET_VALUE ||
    type == RequestType.PRESS_BUTTON ||
    // type == RequestType.CLOSE_SCREEN ||
    type == RequestType.NAVIGATION ||
    type == RequestType.DEVICE_STATUS ||
    type == RequestType.UPLOAD ||
    type == RequestType.DOWNLOAD ||
    type == RequestType.CHANGE ||
    type == RequestType.UPLOAD ||
    type == RequestType.DAL_FILTER ||
    type == RequestType.DAL_DELETE ||
    type == RequestType.RELOAD ||
    type == RequestType.DAL_INSERT ||
    type == RequestType.DAL_SAVE ||
    type == RequestType.DAL_METADATA) ||
    type == RequestType.SET_VALUE;
}

abstract class Request extends Equatable {
  int sequenceNo;
  RequestType requestType;
  bool isProcessing = false;
  String clientId;
  Request subsequentRequest;
  bool reload = false;

  Request({this.requestType, this.clientId});

  Map<String, dynamic> toJson();
}
