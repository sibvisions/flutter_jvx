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
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_download_command.dart';
import '../../i_command_processor.dart';

class SaveOrShowFileCommandProcessor extends ICommandProcessor<SaveOrShowFileCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveOrShowFileCommand command, BaseCommand? origin) async {
    String extension = path.extension(command.fileName);
    if (extension.startsWith(".")) {
      extension = extension.substring(1);
    }

    // Web should not download, web already launches the url directly.
    // It is still here because that is how it was before.
    // see in: {DownloadActionCommandProcessor}
    if (command.showFile || kIsWeb) {
      // saveAs is not implemented for web.
      unawaited(
        FileSaver.instance.saveFile(
          name: path.basenameWithoutExtension(command.fileName),
          bytes: command.content,
          fileExtension: extension,
          mimeType: MimeType.other,
        )
            .then((String filePath) {
          if (command.showFile && !kIsWeb) {
            OpenFilex.open(filePath);
          }
        }),
      );
    } else {
      unawaited(
        FileSaver.instance.saveAs(
          name: path.basenameWithoutExtension(command.fileName),
          bytes: command.content,
          fileExtension: extension,
          mimeType: MimeType.other,
        ),
      );
    }

    return [];
  }
}
