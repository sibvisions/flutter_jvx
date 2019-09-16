import 'package:flutter/foundation.dart';
import 'package:jvx_mobile_v3/di/dependency_injection.dart';
import 'package:jvx_mobile_v3/model/data/data/select_record_resp.dart';
import 'package:jvx_mobile_v3/model/data/select_record.dart';
import 'package:jvx_mobile_v3/model/filter.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/real/real_select_record_service.dart';

class SelectRecordViewModel {
  String clientId;
  String dataProvider;
  bool fetch = false;
  Filter filter;
  NetworkServiceResponse apiResult;
  SelectRecordService selectRecordRepo = Injector().selectRecordService;

  SelectRecordViewModel({@required this.clientId, @required this.dataProvider, 
      @required this.filter, this.fetch});

  Future<Null> performSelectRecord(SelectRecordViewModel selectRecordViewModel) async {
    NetworkServiceResponse<SelectRecordResponse> result = 
      await selectRecordRepo.fetchSelectRecord(
        SelectRecord(clientId: selectRecordViewModel.clientId,
        dataProvider: selectRecordViewModel.dataProvider, 
        filter: selectRecordViewModel.filter, 
        fetch: selectRecordViewModel.fetch));
    this.apiResult = result;
  }
}