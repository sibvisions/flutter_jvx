import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../model/command/api/api_command.dart';
import '../../model/command/api/device_status_command.dart';
import '../../model/command/api/download_images_command.dart';
import '../../model/command/api/download_style_command.dart';
import '../../model/command/api/download_translation_command.dart';
import '../../model/command/base_command.dart';
import '../../model/command/config/config_command.dart';
import '../../model/command/data/data_command.dart';
import '../../model/command/layout/layout_command.dart';
import '../../model/command/ui/ui_command.dart';
import 'i_command_progress_handler.dart';
import 'loading_overlay.dart';

/// The [LoadingProgressHandler] shows a loading progress if a request is over its defined threshold for the wait time.
class LoadingProgressHandler implements ICommandProgressHandler {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Amount of requests that have called for a loading progress.
  int _loadingCommandAmount = 0;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void notifyProgressStart(BaseCommand pCommand) {
    if (isSupported(pCommand) && !IConfigService().isOffline()) {
      _loadingCommandAmount++;
      LoadingOverlayState.of(FlutterJVx.getCurrentContext())?.show(pCommand.loadingDelay);
    }
  }

  @override
  void notifyProgressEnd(BaseCommand pCommand) {
    if (isSupported(pCommand)) {
      if (_loadingCommandAmount > 0) {
        _loadingCommandAmount--;
      }
      if (_loadingCommandAmount == 0) {
        LoadingOverlayState.of(FlutterJVx.getCurrentContext())?.hide();
      }
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  bool isSupported(BaseCommand pCommand) {
    if (pCommand is LayoutCommand) {
      return false;
    }

    if (pCommand is ConfigCommand) {
      return false;
    }

    if (pCommand is UiCommand) {
      return false;
    }

    if (pCommand is DataCommand) {
      return pCommand.showLoading;
    }

    if (pCommand is ApiCommand) {
      if (pCommand is DeviceStatusCommand ||
          pCommand is DownloadImagesCommand ||
          pCommand is DownloadStyleCommand ||
          pCommand is DownloadTranslationCommand) {
        return false;
      }
      return pCommand.showLoading;
    }

    return pCommand.showLoading;
  }
}
