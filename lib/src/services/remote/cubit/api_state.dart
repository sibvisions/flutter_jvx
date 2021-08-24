part of 'api_cubit.dart';

@immutable
abstract class ApiState {}

class ApiInitial extends ApiState {}

class ApiLoading extends ApiState {
  final bool stop;

  ApiLoading({this.stop = false});
}

class ApiResponse extends ApiState {
  final DateTime timestamp;
  final Request request;
  final List<ResponseObject> _objects;
  final Map<String, int> _indices;

  ApiResponse({required this.request, required List<ResponseObject> objects})
      : _objects = objects,
        _indices = _getIndicesFromObjects(objects),
        timestamp = DateTime.now();

  factory ApiResponse.fromJson(Request request, List<dynamic> list) {
    List<ResponseObject> objects = <ResponseObject>[];

    if (list.isNotEmpty) {
      for (final responseObject in list) {
        ResponseObjectType? type;

        if (responseObject['name'] != null) {
          type = getResponseObjectTypeEnum(responseObject['name']);
        } else if (responseObject['name'] == null &&
            request is ApplicationStyleRequest) {
          type = ResponseObjectType.APPLICATION_STYLE;
        }

        if (type != null) {
          switch (type) {
            case ResponseObjectType.APPLICATIONMETADATA:
              objects.add(ApplicationMetaDataResponseObject.fromJson(
                  map: responseObject));
              break;
            case ResponseObjectType.APPLICATION_STYLE:
              objects.add(
                  ApplicationStyleResponseObject.fromJson(map: responseObject));
              break;
            case ResponseObjectType.LANGUAGE:
              objects.add(LanguageResponseObject.fromJson(map: responseObject));
              break;
            case ResponseObjectType.SCREEN_GENERIC:
              objects.add(
                  ScreenGenericResponseObject.fromJson(map: responseObject));
              break;
            case ResponseObjectType.DAL_FETCH:
              objects.add(DataBook.fromJson(map: responseObject));
              break;
            case ResponseObjectType.DAL_METADATA:
              objects.add(DataBookMetaData.fromJson(map: responseObject));
              break;
            case ResponseObjectType.DAL_DATAPROVIDERCHANGED:
              objects.add(DataproviderChanged.fromJson(map: responseObject));
              break;
            case ResponseObjectType.LOGIN:
              objects.add(LoginResponseObject.fromJson(map: responseObject));
              break;
            case ResponseObjectType.MENU:
              objects.add(MenuResponseObject.fromJson(map: responseObject));
              break;
            case ResponseObjectType.AUTHENTICATIONDATA:
              objects.add(AuthenticationDataResponseObject.fromJson(
                  map: responseObject));
              break;
            case ResponseObjectType.DOWNLOAD:
              objects.add(
                  DownloadActionResponseObject.fromJson(map: responseObject));
              break;
            case ResponseObjectType.UPLOAD:
              objects.add(
                  UploadActionResponseObject.fromJson(map: responseObject));
              break;
            case ResponseObjectType.CLOSESCREEN:
              objects.add(CloseScreenActionResponseObject.fromJson(
                  map: responseObject));
              break;
            case ResponseObjectType.USERDATA:
              objects.add(UserDataResponseObject.fromJson(map: responseObject));
              break;
            case ResponseObjectType.SHOWDOCUMENT:
              objects.add(
                  ShowDocumentResponseObject.fromJson(map: responseObject));
              break;
            case ResponseObjectType.DEVICESTATUS:
              objects.add(
                  DeviceStatusResponseObject.fromJson(map: responseObject));
              break;
            case ResponseObjectType.RESTART:
              objects.add(RestartResponseObject.fromJson(map: responseObject));
              break;
            case ResponseObjectType.ERROR:
              objects.add(Failure.fromJson(map: responseObject));
              break;
            case ResponseObjectType.APPLICATIONPARAMETERS:
              objects.add(ApplicationParametersResponseObject.fromJson(
                  map: responseObject));
              break;
          }
        }
      }
    }

    return ApiResponse(objects: objects, request: request);
  }

  List<ResponseObject> get objects => _objects;

  bool get hasError => this.getObjectByType<Failure>() != null;

  bool get hasDataObject => getAllDataObjects().isNotEmpty;

  bool get hasDataBook => hasObject<DataBook>();

  bool get hasMetaDataBook => hasObject<DataBookMetaData>();

  bool get hasDataProviderChanged => hasObject<DataproviderChanged>();

  DataBook? getDataBookByProvider(String dataProvider) {
    DataBook? dataBook;

    for (final d in _objects.whereType<DataBook>().toList()) {
      if (d.dataProvider == dataProvider) {
        dataBook = d;
      }
    }

    return dataBook;
  }

  ResponseObject? getObjectByName(String name) {
    int? index = _indices[name];

    if (index != null) {
      return _objects[index];
    }

    return null;
  }

  T? getObjectByType<T>() {
    T? toReturn;

    for (final object in _objects) {
      if (object is T) {
        toReturn = object as T;
      }
    }

    return toReturn;
  }

  bool hasObject<T>() => getObjectByType<T>() != null;

  List<T> getAllObjectsByType<T extends ResponseObject>() {
    List<T> toReturn = _objects.whereType<T>().toList();

    return toReturn;
  }

  List<ResponseObject> getAllDataObjects() {
    List<DataBook> dataBooks = getAllObjectsByType<DataBook>();
    List<DataBookMetaData> dataBookMetaDatas =
        getAllObjectsByType<DataBookMetaData>();
    List<DataproviderChanged> dpcs = getAllObjectsByType<DataproviderChanged>();

    return <ResponseObject>[
      ...dataBooks,
      ...dataBookMetaDatas,
      ...dpcs,
    ];
  }

  void addResponseObject(ResponseObject responseObject) {
    if (!_objects.contains(responseObject)) _objects.add(responseObject);
  }

  static Map<String, int> _getIndicesFromObjects(List<ResponseObject> objects) {
    Map<String, int> indices = <String, int>{};

    if (objects.isNotEmpty) {
      for (final object in objects) {
        indices[object.name] = objects.indexOf(object);
      }
    }

    return indices;
  }
}

class ApiError extends ApiState {
  final List<Failure> failures;

  ApiError({required this.failures});
}
