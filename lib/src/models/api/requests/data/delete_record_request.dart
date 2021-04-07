import '../../response_objects/response_data/data/filter.dart';
import 'data_request.dart';

class DeleteRecordRequest extends DataRequest {
  bool fetch;
  Filter? filter = Filter();
  int? selectedRow;

  DeleteRecordRequest(
      {required String clientId,
      required String dataProvider,
      String? debugInfo,
      bool reload = false,
      required this.filter,
      this.selectedRow,
      this.fetch = false})
      : super(
            clientId: clientId,
            dataProvider: dataProvider,
            debugInfo: debugInfo,
            reload: reload);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'fetch': fetch,
        'filter': filter?.toJson(),
        'selectedRow': selectedRow,
        ...super.toJson()
      };
}
