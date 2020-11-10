import '../../request.dart';

class MetaData extends Request {
  String dataProvider;
  List<dynamic> columnNames;

  MetaData(this.dataProvider, String clientId, [this.columnNames])
      : super(RequestType.DAL_METADATA, clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'dataProvider': dataProvider,
        'columnNames': columnNames,
      };
}
