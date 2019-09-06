import 'dart:async';

import 'package:jvx_mobile_v3/logic/viewmodel/close_screen_view_model.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:rxdart/subjects.dart';

class CloseScreenBloc {
  final closeScreenController = StreamController<CloseScreenViewModel>();
  final apiController = BehaviorSubject<FetchProcess>();
  final closeScreenResendController = StreamController<bool>();
  final closeScreenResultController = BehaviorSubject<bool>();
  Sink<CloseScreenViewModel> get closeScreenSink => closeScreenController.sink;
  Sink<bool> get resendCloseScreenSink => closeScreenResendController.sink;
  Stream<bool> get closeScreenResult => closeScreenResultController.stream.asBroadcastStream();
  Stream<FetchProcess> get apiResult => apiController.stream.asBroadcastStream();

  CloseScreenBloc() {
    closeScreenController.stream.listen(apiCall);
    closeScreenResendController.stream.listen(resendCloseScreen);
  }

  void apiCall(CloseScreenViewModel closeScreenViewModel) async {
    FetchProcess process = new FetchProcess(loading: true);
    apiController.add(process);
    process.type = ApiType.performCloseScreen;
    await closeScreenViewModel.performCloseScreen(closeScreenViewModel);

    process.loading = false;
    process.response = closeScreenViewModel.apiResult;
    apiController.add(process);
    closeScreenViewModel = null;
  }

  void resendCloseScreen(bool flag) {
    closeScreenResultController.add(false);
  }

  void dispose() {
    closeScreenController.close();
    closeScreenResendController.close();
    apiController.close();
    closeScreenResultController.close();
  }
}