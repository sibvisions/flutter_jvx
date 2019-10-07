enum ResponseObjectType {
  APPLICATIONMETADATA,
  LANGUAGE,
  SCREEN_GENERIC,
  DAL_FETCH,
  DAL_META_DATA,
  LOGIN,
  MENU,
  AUTHENTICATIONDATA
}

ResponseObjectType getResponseObjectTypeEnum(String responseObjectType) {
  responseObjectType = 'ResponseObjectType.${responseObjectType.toUpperCase()}';

  return ResponseObjectType.values.firstWhere(
      (f) => f.toString().replaceFirst('.', '_', 19) == responseObjectType,
      orElse: () => null);
}

abstract class ResponseObject<T> {
  ResponseObjectType type;
  T object;
  String name;

  ResponseObject();

  ResponseObject.fromJson(Map<String, dynamic> json)
    : name = json['name'];
}
