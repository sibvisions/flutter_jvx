import 'dart:async';

import 'package:jvx_mobile_v3/logic/viewmodel/application_style_view_model.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:rxdart/rxdart.dart';

class ApplicationStyleBloc {
  final applicationStyleController = StreamController<ApplicationStyleViewModel>();
  final apiController = BehaviorSubject<FetchProcess>();
  final applicationStyleResendController = StreamController<bool>();
  final applicationStyleResultController = BehaviorSubject<bool>();
  Sink<ApplicationStyleViewModel> get applicationStyleSink => applicationStyleController.sink;
  Sink<bool> get resendapplicationStyleSink => applicationStyleResendController.sink;
  Stream<bool> get applicationStyleResult => applicationStyleResultController.stream;
  Stream<FetchProcess> get apiResult => apiController.stream;

  ApplicationStyleBloc() {
    applicationStyleController.stream.listen(apiCall);
    applicationStyleResendController.stream.listen(resendApplicationStyle);
  }

  void apiCall(ApplicationStyleViewModel applicationStyleViewModel) async {
    FetchProcess process = new FetchProcess(loading: true);
    apiController.add(process);
    process.type = ApiType.performApplicationStyle;
    await applicationStyleViewModel.performApplicationStyle(applicationStyleViewModel);

    process.loading = false;
    process.response = applicationStyleViewModel.apiResult;
    apiController.add(process);
    applicationStyleViewModel = null;
  }

  void resendApplicationStyle(bool flag) {
    applicationStyleResultController.add(false);
  }

  void dispose() {
    applicationStyleController.close();
    applicationStyleResendController.close();
    apiController.close();
    applicationStyleResultController.close();
  }
}