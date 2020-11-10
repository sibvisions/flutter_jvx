import '../../../../ui/screen/so_component_data.dart';
import '../../request.dart';
import '../../response/data/filter.dart';

class SelectRecord extends Request {
  String dataProvider;
  bool fetch;
  Filter filter = Filter();
  int selectedRow;
  SoComponentData soComponentData;

  SelectRecord(this.dataProvider, this.filter, this.selectedRow,
      RequestType requestType, String clientId,
      [this.fetch])
      : super(requestType, clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'dataProvider': dataProvider,
        'fetch': fetch,
        'filter': filter?.toJson(),
        'selectedRow': selectedRow
      };
}
