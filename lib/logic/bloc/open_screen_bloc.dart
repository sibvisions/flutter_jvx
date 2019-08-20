import 'dart:async';

import 'package:jvx_mobile_v3/logic/viewmodel/open_screen_view_model.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:rxdart/subjects.dart';

class OpenScreenBloc {
  final openScreenController = StreamController<OpenScreenViewModel>();
  final apiController = BehaviorSubject<FetchProcess>();
  final openScreenResendController = StreamController<bool>();
  final openScreenResultController = BehaviorSubject<bool>();
  Sink<OpenScreenViewModel> get openScreenSink => openScreenController.sink;
  Sink<bool> get resendOpenScreenSink => openScreenResendController.sink;
  Stream<bool> get openScreenResult => openScreenResultController.stream;
  Stream<FetchProcess> get apiResult => apiController.stream;

  OpenScreenBloc() {
    openScreenController.stream.listen(apiCall);
    openScreenResendController.stream.listen(resendOpenScreen);
  }

  void apiCall(OpenScreenViewModel openScreenViewModel) async {
    FetchProcess process = new FetchProcess(loading: true);
    apiController.add(process);
    process.type = ApiType.performOpenScreen;
    await openScreenViewModel.performOpenScreen(openScreenViewModel);

    process.loading = false;
    process.response = openScreenViewModel.apiResult;
    apiController.add(process);
    openScreenViewModel = null;
  }

  void resendOpenScreen(bool flag) {
    openScreenResultController.add(false);
  }

  void dispose() {
    openScreenController.close();
    openScreenResendController.close();
    apiController.close();
    openScreenResultController.close();
  }
}