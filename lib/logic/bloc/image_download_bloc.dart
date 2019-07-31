import 'dart:async';

import 'package:jvx_mobile_v3/logic/viewmodel/image_download_view_model.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:rxdart/subjects.dart';

/// Business Logic Component for downloading the image files needed for the application.
/// 
/// Handels State from the response and request with [Stream]s and [Sink]s.
/// All state Management which is connected with the image downloading is handled through this class.
class ImageDownloadBloc {
  final imageDownloadController = StreamController<ImageDownloadViewModel>();
  final apiController = BehaviorSubject<FetchProcess>();
  final imageDownloadResendController = StreamController<bool>();
  final imageDownloadResultController = BehaviorSubject<bool>();
  Sink<ImageDownloadViewModel> get imageDownloadSink => imageDownloadController.sink;
  Sink<bool> get resendImageDownloadSink => imageDownloadResendController.sink;
  Stream<bool> get imageDownloadResult => imageDownloadResultController.stream;
  Stream<FetchProcess> get apiResult => apiController.stream;

  /// on build of a [ImageDownloadBloc] a listener is inisiated and listens to the [imageDownloadController]
  /// 
  /// also the a listener listens to the [imageDownloadResendController]
  ImageDownloadBloc() {
    imageDownloadController.stream.listen(apiCall);
    imageDownloadResendController.stream.listen(resendImageDownload);
  }

  /// This method calls the [performImageDownload] method which sends the call to the rest service.
  /// 
  /// As a parameter a [ImageDownloadViewModel] will be given
  void apiCall(ImageDownloadViewModel imageDownloadViewModel) async {
    FetchProcess process = new FetchProcess(loading: true);
    apiController.add(process);
    process.type = ApiType.performImageDownload;
    await imageDownloadViewModel.performImageDownload(imageDownloadViewModel);

    process.loading = false;
    process.response = imageDownloadViewModel.apiResult;
    apiController.add(process);
    imageDownloadViewModel = null;
  }

  /// method for resending the request to download the images
  void resendImageDownload(bool flag) {
    imageDownloadResendController.add(false);
  }

  /// disposing of all of the controllers when not needed anymore
  void dispose() {
    imageDownloadController.close();
    imageDownloadResendController.close();
    apiController.close();
    imageDownloadResultController.close();
  }
}