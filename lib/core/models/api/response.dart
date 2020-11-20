import 'request.dart';
import 'response/application_meta_data.dart';
import 'response/application_style_response.dart';
import 'response/auth_data.dart';
import 'response/close_screen_action.dart';
import 'response/data/data_book.dart';
import 'response/data/dataprovider_changed.dart';
import 'response/device_status_response.dart';
import 'response/download_action.dart';
import 'response/download_response.dart';
import 'response/error_response.dart';
import 'response/language.dart';
import 'response/login_item.dart';
import 'response/menu.dart';
import 'response/meta_data/data_book_meta_data.dart';
import 'response/response_data.dart';
import 'response/restart.dart';
import 'response/screen_generic.dart';
import 'response/show_document.dart';
import 'response/upload_action.dart';
import 'response/user_data.dart';
import 'response_object.dart';

class Response {
  Request request;

  ErrorResponse error;
  ApplicationStyleResponse applicationStyle;
  Language language;
  LoginItem loginItem;
  Menu menu;
  Restart restart;
  ApplicationMetaData applicationMetaData;
  AuthenticationData authenticationData;
  CloseScreenAction closeScreenAction;
  DeviceStatusResponse deviceStatusResponse;
  DownloadAction downloadAction;
  UploadAction uploadAction;
  UserData userData;
  ResponseData responseData = ResponseData();
  DownloadResponse downloadResponse;
  ShowDocument showDocument;

  bool get hasError => error != null;

  Response();

  static ErrorResponse checkForError(Map<String, dynamic> json) {
    if (json != null &&
        (json['title'] == 'Error' ||
            json['title'] == 'Session Expired' ||
            json['name'] == 'message.information')) {
      return ErrorResponse(
          json['title'], json['details'], json['message'], json['name']);
    }
    return null;
  }

  Response.fromJson(List<dynamic> json) {
    var errorR;

    if (json.isNotEmpty) {
      json.forEach((e) => errorR = checkForError(e));
    }

    error = errorR;

    if (json.isNotEmpty) {
      json.forEach((responseObject) {
        ResponseObjectType type =
            getResponseObjectTypeEnum(responseObject['name']);

        if (type != null) {
          switch (type) {
            case ResponseObjectType.APPLICATIONMETADATA:
              applicationMetaData =
                  ApplicationMetaData.fromJson(responseObject);
              break;
            case ResponseObjectType.LANGUAGE:
              language = Language.fromJson(responseObject);
              break;
            case ResponseObjectType.SCREEN_GENERIC:
              if (responseObject['changedComponents'] != null)
                responseData.screenGeneric =
                    ScreenGeneric.fromChangedComponentsJson(responseObject);
              else
                responseData.screenGeneric =
                    ScreenGeneric.fromUpdateComponentsJson(responseObject);
              break;
            case ResponseObjectType.DAL_FETCH:
              responseData.dataBooks.add(DataBook.fromJson(responseObject));
              break;
            case ResponseObjectType.DAL_METADATA:
              responseData.dataBookMetaData
                  .add(DataBookMetaData.fromJson(responseObject));
              break;
            case ResponseObjectType.DAL_DATAPROVIDERCHANGED:
              responseData.dataproviderChanged
                  .add(DataproviderChanged.fromJson(responseObject));
              break;
            case ResponseObjectType.LOGIN:
              loginItem = LoginItem.fromJson(responseObject);
              break;
            case ResponseObjectType.MENU:
              menu = Menu.fromJson(responseObject);
              break;
            case ResponseObjectType.AUTHENTICATIONDATA:
              authenticationData = AuthenticationData.fromJson(responseObject);
              break;
            case ResponseObjectType.DOWNLOAD:
              downloadAction = DownloadAction.fromJson(responseObject);
              break;
            case ResponseObjectType.UPLOAD:
              uploadAction = UploadAction.fromJson(responseObject);
              break;
            case ResponseObjectType.CLOSESCREEN:
              closeScreenAction = CloseScreenAction.fromJson(responseObject);
              break;
            case ResponseObjectType.USERDATA:
              userData = UserData.fromJson(responseObject);
              break;
            case ResponseObjectType.SHOWDOCUMENT:
              showDocument = ShowDocument.fromJson(responseObject);
              break;
            case ResponseObjectType.DEVICESTATUS:
              deviceStatusResponse =
                  DeviceStatusResponse.fromJson(responseObject);
              break;
            case ResponseObjectType.RESTART:
              restart = Restart.fromJson(responseObject);
              break;
            case ResponseObjectType.ERROR:
              error = ErrorResponse.fromJson(responseObject);
              break;
            case ResponseObjectType.APPLICATION_STYLE:
              applicationStyle =
                  ApplicationStyleResponse.fromJson(responseObject);
              break;
          }
        } else {
          error = ErrorResponse('Error', 'Couldn\'t parse Response',
              'An Error occured', 'message.error');
        }
      });
    }
  }

  copyFrom(Response response) {
    this.applicationMetaData = response.applicationMetaData;
    this.applicationStyle = response.applicationStyle;
    this.authenticationData = response.authenticationData;
    this.closeScreenAction = response.closeScreenAction;
    this.deviceStatusResponse = response.deviceStatusResponse;
    this.downloadAction = response.downloadAction;
    this.downloadResponse = response.downloadResponse;
    this.error = response.error;
    this.language = response.language;
    this.loginItem = response.loginItem;
    this.menu = response.menu;
    this.request = response.request;
    this.responseData = response.responseData;
    this.restart = response.restart;
    this.showDocument = response.showDocument;
    this.uploadAction = response.uploadAction;
    this.userData = response.userData;
  }
}
