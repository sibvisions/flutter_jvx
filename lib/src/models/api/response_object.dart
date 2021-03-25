enum ResponseObjectType {
  APPLICATIONMETADATA,
  APPLICATION_STYLE,
  LANGUAGE,
  SCREEN_GENERIC,
  DAL_FETCH,
  DAL_METADATA,
  DAL_DATAPROVIDERCHANGED,
  LOGIN,
  MENU,
  AUTHENTICATIONDATA,
  DOWNLOAD,
  UPLOAD,
  CLOSESCREEN,
  USERDATA,
  SHOWDOCUMENT,
  DEVICESTATUS,
  RESTART,
  ERROR,
  APPLICATIONPARAMETERS
}

ResponseObjectType? getResponseObjectTypeEnum(String responseObjectType) {
  if (responseObjectType == 'message.error' ||
      responseObjectType == 'message.information') {
    return ResponseObjectType.ERROR;
  }

  try {
    responseObjectType =
        'ResponseObjectType.${responseObjectType.toUpperCase()}';

    return ResponseObjectType.values.firstWhere(
      (f) => f.toString() == responseObjectType.replaceFirst('.', '_', 19),
    );
  } on NoSuchMethodError {
    return null;
  } catch (e) {
    return null;
  }
}

class ResponseObject {
  String name;
  String? componentId;

  ResponseObject({required this.name, this.componentId});

  ResponseObject.fromJson({required Map<String, dynamic> map})
      : name = map['name'],
        componentId = map['componentId'];

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'name': name, 'componentId': componentId};
}
