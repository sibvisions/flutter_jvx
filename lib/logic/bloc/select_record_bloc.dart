import 'dart:async';
import 'package:jvx_mobile_v3/logic/viewmodel/select_record_view_model.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:rxdart/rxdart.dart';

class SelectRecordBloc {
  final selectRecordController = StreamController<SelectRecordViewModel>();
  final apiController = BehaviorSubject<FetchProcess>();
  final selectRecordResendController = StreamController<bool>();
  final selectRecordResultController = BehaviorSubject<bool>();
  Sink<SelectRecordViewModel> get pressButtonSink => selectRecordController.sink;
  Sink<bool> get resendSelectRecordSink => selectRecordResendController.sink;
  Stream<bool> get selectRecordResult => selectRecordResultController.stream;
  Stream<FetchProcess> get apiResult => apiController.stream;

  SelectRecordBloc() {
    selectRecordController.stream.listen(apiCall);
    selectRecordResendController.stream.listen(resendSelectRecord);
  }

  void apiCall(SelectRecordViewModel selectRecordViewModel) async {
    FetchProcess process = new FetchProcess(loading: true);
    apiController.add(process);
    process.type = ApiType.performPressButton;
    await selectRecordViewModel.performSelectRecord(selectRecordViewModel);

    process.loading = false;
    process.response = selectRecordViewModel.apiResult;
    apiController.add(process);
    selectRecordViewModel = null;
  }

  void resendSelectRecord(bool flag) {
    selectRecordResultController.add(false);
  }

  void dispose() {
    selectRecordController.close();
    selectRecordResendController.close();
    apiController.close();
    selectRecordResultController.close();
  }
}