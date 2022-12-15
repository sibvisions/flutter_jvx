/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import '../../flutter_ui.dart';
import '../../mask/jvx_overlay.dart';
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
import '../../service/config/config_service.dart';
import 'i_command_progress_handler.dart';

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
    if (isSupported(pCommand) && !ConfigService().isOffline()) {
      _loadingCommandAmount++;
      JVxOverlayState.of(FlutterUI.getCurrentContext())?.showLoading(pCommand.loadingDelay);
    }
  }

  @override
  void notifyProgressEnd(BaseCommand pCommand) {
    if (isSupported(pCommand)) {
      if (_loadingCommandAmount > 0) {
        _loadingCommandAmount--;
      }
      if (_loadingCommandAmount == 0) {
        JVxOverlayState.of(FlutterUI.getCurrentContext())?.hideLoading();
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
