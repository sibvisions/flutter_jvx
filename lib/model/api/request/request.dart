import 'package:equatable/equatable.dart';

enum RequestType { STARTUP, LOGIN, LOGOUT, OPEN_SCREEN, CLOSE_SCREEN, DOWNLOAD_TRANSLATION, DOWNLOAD_IMAGES, DOWNLOAD_APP_STYLE, DAL_SELECT_RECORD, DAL_SET_VALUE, DAL_FETCH }

abstract class Request extends Equatable {
  RequestType requestType;
  String clientId;

  Request({this.requestType, this.clientId});

  Map<String, dynamic> toJson();
}