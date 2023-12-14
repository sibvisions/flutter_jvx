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

import '../../../../../model/command/api/upload_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/upload_action_command.dart';
import '../../../../../util/widgets/file_picker_dialog.dart';
import '../../../i_command_service.dart';
import '../../i_command_processor.dart';

class UploadActionCommandProcessor extends ICommandProcessor<UploadActionCommand> {
  @override
  Future<List<BaseCommand>> processCommand(UploadActionCommand command, BaseCommand? origin) async {
    unawaited(FilePickerDialog.openFilePicker().then((value) {
      if (value != null) {
        ICommandService().sendCommand(UploadCommand(fileId: command.fileId, file: value, reason: "Uploading file"));
      }
    }));

    return [];
  }
}
