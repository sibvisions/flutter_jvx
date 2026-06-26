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
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:cross_file/cross_file.dart';

import '../../../../../model/command/api/upload_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/upload_action_command.dart';
import '../../../../../model/data/data_book.dart';
import '../../../../../util/widgets/file_picker_dialog.dart';
import '../../../../data/i_data_service.dart';
import '../../../i_command_service.dart';
import '../../i_command_processor.dart';

class UploadActionCommandProcessor extends ICommandProcessor<UploadActionCommand> {
  @override
  Future<List<BaseCommand>> processCommand(UploadActionCommand command, BaseCommand? origin) async {
    unawaited(FilePickerDialog.openFilePicker().then((value) async {
      if (value != null) {
        if (command.url != null) {
          Uri? uri = Uri.tryParse(command.url!);

          if (uri != null) {
            String? columnName = uri.queryParameters['cnm'];
            String? dataProvider = uri.queryParameters['dpv'];

            if (dataProvider != null && columnName != null) {
              DataBook? book = IDataService().getDataBook(dataProvider);

              if (book?.isEncodedDataType(columnName) == true) {

                Uint8List fileData = await value.readAsBytes();

                dynamic encryptedValue = await book!.encryptValue(fileData);

                if (encryptedValue is String) {
                  encryptedValue = utf8.encode(encryptedValue);
                }

                //only encrypt value is necessary
                if (fileData.length != (encryptedValue as Uint8List).length
                    || !fileData.equals(encryptedValue)) {
                  value = XFile.fromData(encryptedValue,
                    name: value.name,
                    mimeType: value.mimeType,
                    path: value.path
                  );
                }
              }
            }
          }
        }

        unawaited(ICommandService().sendCommand(UploadCommand(fileId: command.fileId, file: value, reason: "Uploading file")));
      }
    }));

    return [];
  }
}
