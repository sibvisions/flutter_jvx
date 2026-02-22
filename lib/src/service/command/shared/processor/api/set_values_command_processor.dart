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

import '../../../../../model/command/api/set_values_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/data/column_definition.dart';
import '../../../../../model/data/data_book.dart';
import '../../../../../model/request/api_set_values_request.dart';
import '../../../../../util/i_types.dart';
import '../../../../api/i_api_service.dart';
import '../../../../data/i_data_service.dart';
import '../../i_command_processor.dart';

class SetValuesCommandProcessor extends ICommandProcessor<SetValuesCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SetValuesCommand command, BaseCommand? origin) async {

    DataBook? book = IDataService().getDataBook(command.dataProvider);

    List<dynamic>? valuesEncrypted;

    if (book != null) {
      DalMetaData? metaData = book.metaData;

      if (metaData != null) {
        ColumnDefinition? colDef;

        for (int i = 0; i < command.columnNames.length; i++) {
          colDef = metaData.columnDefinitions.byName(command.columnNames[i]);

          if (colDef?.dataTypeIdentifier == Types.ENCODED_BINARY) {
            valuesEncrypted ??= List.from(command.values);

            valuesEncrypted[i] = await book.encryptValue(valuesEncrypted[i]);
          }
        }
      }
    }

    return IApiService().sendRequest(
      ApiSetValuesRequest(
        dataProvider: command.dataProvider,
        columnNames: command.columnNames,
        editorColumnName: command.editorColumnName,
        values: valuesEncrypted ?? command.values,
        filter: command.filter,
        rowNumber: command.rowNumber,
      ),
    );
  }
}
