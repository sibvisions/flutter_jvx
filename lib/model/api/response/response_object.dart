enum ResponseObjectType {
  APPLICATIONMETADATA,
  LANGUAGE,
  SCREEN_GENERIC,
  DAL_FETCH,
  DAL_METADATA,
  LOGIN,
  MENU,
  AUTHENTICATIONDATA,
  DOWNLOAD,
  UPLOAD,
  CLOSESCREEN
}

ResponseObjectType getResponseObjectTypeEnum(String responseObjectType) {
  responseObjectType = 'ResponseObjectType.${responseObjectType.toUpperCase()}';

  return ResponseObjectType.values.firstWhere(
      (f) => f.toString() == responseObjectType.replaceFirst('.', '_', 19),
      orElse: () => null);
}

abstract class ResponseObject<T> {
  ResponseObjectType type;
  T object;
  String name;
  String componentId;

  ResponseObject();

  ResponseObject.fromJson(Map<String, dynamic> json)
    : componentId = json['componentId'],
      name = json['name'];
}
