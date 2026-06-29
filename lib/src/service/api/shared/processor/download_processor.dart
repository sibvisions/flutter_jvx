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

import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_download_command.dart';
import '../../../../model/data/data_book.dart';
import '../../../../model/request/api_download_request.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/download_response.dart';
import '../../../../util/crypto_util.dart';
import '../../../data/i_data_service.dart';
import '../i_response_processor.dart';

class DownloadProcessor implements IResponseProcessor<DownloadResponse> {
  @override
  Future<List<BaseCommand>> processResponse(DownloadResponse response, ApiRequest? request) async {
    if (request is ApiDownloadRequest) {
      Uint8List data = response.bodyBytes;

      Uri? uri = Uri.tryParse(request.url);

      if (uri != null) {
        String? columnName = uri.queryParameters['cnm'];
        String? dataProvider = uri.queryParameters['dpv'];

        if (dataProvider != null && columnName != null) {
          DataBook? book = IDataService().getDataBook(dataProvider);

          if (book?.isEncodedDataType(columnName) == true) {
            DecryptedValue decValue = await book!.decryptValue(data);

            if (decValue.value is String) {
              data = utf8.encode(decValue.value as String);
            }
            else {
              data = decValue.value;
            }
          }
        }
      }

      return [
        SaveOrShowFileCommand(
          content: data,
          fileId: request.fileId,
          fileName: request.fileName,
          showFile: request.showFile,
          reason: "${request.showFile ? "Showing" : "Saving"} a file",
        )
      ];
    } else {
      return [];
    }
  }
}
