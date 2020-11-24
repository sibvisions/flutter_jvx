import '../../request.dart';

class InsertRecord extends Request {
  String dataProvider;

  @override
  String get debugInfo {
    return dataProvider;
  }

  InsertRecord(this.dataProvider, String clientId)  : 
      super(RequestType.DAL_INSERT, clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'dataProvider': dataProvider,
  };
}