import 'dart:async';

import 'package:jvx_mobile_v3/logic/viewmodel/download_view_model.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:rxdart/subjects.dart';

/// Business Logic Component for downloading the image files needed for the application.
/// 
/// Handels State from the response and request with [Stream]s and [Sink]s.
/// All state Management which is connected with the image downloading is handled through this class.
class DownloadBloc {
  final downloadController = StreamController<DownloadViewModel>();
  final apiController = BehaviorSubject<FetchProcess>();
  final downloadResendController = StreamController<bool>();
  final downloadResultController = BehaviorSubject<bool>();
  Sink<DownloadViewModel> get downloadSink => downloadController.sink;
  Sink<bool> get resendDownloadSink => downloadResendController.sink;
  Stream<bool> get downloadResult => downloadResultController.stream;
  Stream<FetchProcess> get apiResult => apiController.stream;

  /// on build of a [DownloadBloc] a listener is inisiated and listens to the [downloadController]
  /// 
  /// also the a listener listens to the [downloadResendController]
  DownloadBloc() {
    downloadController.stream.listen(apiCall);
    downloadResendController.stream.listen(resendDownload);
  }

  /// This method calls the [performDownload] method which sends the call to the rest service.
  /// 
  /// As a parameter a [DownloadViewModel] will be given
  void apiCall(DownloadViewModel downloadViewModel) async {
    FetchProcess process = new FetchProcess(loading: true);
    apiController.add(process);
    process.type = ApiType.performDownload;
    await downloadViewModel.performDownload(downloadViewModel);

    process.loading = false;
    process.response = downloadViewModel.apiResult;
    apiController.add(process);
    downloadViewModel = null;
  }

  /// method for resending the request to download the images
  void resendDownload(bool flag) {
    downloadResendController.add(false);
  }

  /// disposing of all of the controllers when not needed anymore
  void dispose() {
    downloadController.close();
    downloadResendController.close();
    apiController.close();
    downloadResultController.close();
  }
}