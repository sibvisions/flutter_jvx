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

import 'dart:async';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_download_command.dart';
import '../../i_command_processor.dart';

class SaveDownloadCommandProcessor implements ICommandProcessor<SaveDownloadCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveDownloadCommand command) async {
    if (kIsWeb) {
      // https://github.com/incrediblezayed/file_saver/issues/42
      // File saver ignores the extension property so we have to include it in the name itself
      unawaited(
        FileSaver.instance.saveFile(
          path.basename(command.fileName),
          command.bodyBytes,
          "",
        ),
      );
    } else {
      String extension = path.extension(command.fileName);
      if (extension.startsWith(".")) {
        extension = extension.substring(1);
      }
      unawaited(
        FileSaver.instance.saveAs(
          path.basenameWithoutExtension(command.fileName),
          command.bodyBytes,
          extension,
          MimeType.OTHER,
        ),
      );
    }

    return [];
  }
}
