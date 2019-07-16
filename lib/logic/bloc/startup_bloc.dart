import 'dart:async';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:rxdart/rxdart.dart';

import 'package:jvx_mobile_v3/logic/viewmodel/startup_view_model.dart';

class StartupBloc {
  final startupController = StreamController<StartupViewModel>();
  final apiController = BehaviorSubject<FetchProcess>();
  final startupResendController = StreamController<bool>();
  final startupResultController = BehaviorSubject<bool>();
  Sink<StartupViewModel> get startupSink => startupController.sink;
  Sink<bool> get resendStartupSink => startupResendController.sink;
  Stream<bool> get startupResult => startupResultController.stream;
  Stream<FetchProcess> get apiResult => apiController.stream;

  StartupBloc() {
    startupController.stream.listen(apiCall);
    startupResendController.stream.listen(resendStartup);
  }

  void apiCall(StartupViewModel startupViewModel) async {
    FetchProcess process = new FetchProcess(loading: true);
    apiController.add(process);
    process.type = ApiType.performStartup;
    await startupViewModel.performStartup(startupViewModel);

    process.loading = false;
    process.response = startupViewModel.apiResult;
    apiController.add(process);
    startupViewModel = null;
  }

  void resendStartup(bool flag) {
    startupResultController.add(false);
  }

  void dispose() {
    startupController.close();
    startupResendController.close();
    apiController.close();
    startupResultController.close();
  }
}