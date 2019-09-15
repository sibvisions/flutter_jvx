import 'package:jvx_mobile_v3/model/filter.dart';

class SelectRecord {
  String clientId;
  String dataProvider;
  bool fetch;
  Filter filter;

  SelectRecord({this.clientId, this.dataProvider, this.fetch, this.filter});

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'dataProvider': dataProvider,
    'fetch': fetch,
    'filter': filter.toJson()
  };
}