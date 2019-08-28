import 'dart:async';

import 'package:jvx_mobile_v3/logic/viewmodel/press_button_view_model.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:rxdart/rxdart.dart';

class PressButtonBloc {
  final pressButtonController = StreamController<PressButtonViewModel>();
  final apiController = BehaviorSubject<FetchProcess>();
  final pressButtonResendController = StreamController<bool>();
  final pressButtonResultController = BehaviorSubject<bool>();
  Sink<PressButtonViewModel> get pressButtonSink => pressButtonController.sink;
  Sink<bool> get resendPressButtonSink => pressButtonResendController.sink;
  Stream<bool> get pressButtonResult => pressButtonResultController.stream;
  Stream<FetchProcess> get apiResult => apiController.stream;

  PressButtonBloc() {
    pressButtonController.stream.listen(apiCall);
    pressButtonResendController.stream.listen(resendPressButton);
  }

  void apiCall(PressButtonViewModel pressButtonViewModel) async {
    FetchProcess process = new FetchProcess(loading: true);
    apiController.add(process);
    process.type = ApiType.performPressButton;
    await pressButtonViewModel.performPressButton(pressButtonViewModel);

    process.loading = false;
    process.response = pressButtonViewModel.apiResult;
    apiController.add(process);
    pressButtonViewModel = null;
  }

  void resendPressButton(bool flag) {
    pressButtonResultController.add(false);
  }

  void dispose() {
    pressButtonController.close();
    pressButtonResendController.close();
    apiController.close();
    pressButtonResultController.close();
  }
}