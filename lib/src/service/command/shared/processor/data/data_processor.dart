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

import 'package:collection/collection.dart';

import '../../../../../flutter_ui.dart';
import '../../../../../model/command/api/fetch_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/data_command.dart';
import '../../../../../model/command/data/delete_provider_data_command.dart';
import '../../../../../model/command/data/delete_row_command.dart';
import '../../../../../model/command/data/get_data_chunk_command.dart';
import '../../../../../model/command/data/get_meta_data_command.dart';
import '../../../../../model/command/data/get_page_chunk_command.dart';
import '../../../../../model/command/data/get_selected_data_command.dart';
import '../../../../../model/command/data/save_fetch_data_command.dart';
import '../../../../../model/command/data/save_meta_data_command.dart';
import '../../../../../model/command/ui/open_error_dialog_command.dart';
import '../../../../../model/data/data_book.dart';
import '../../../../../model/data/subscriptions/data_chunk.dart';
import '../../../../../model/data/subscriptions/data_record.dart';
import '../../../../data/i_data_service.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

/// Sends [DataCommand] to their respective processor
class DataProcessor extends ICommandProcessor<DataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DataCommand command, BaseCommand? origin) async {
    if (command is SaveMetaDataCommand) {
      return _saveMetaData(command);
    } else if (command is SaveFetchDataCommand) {
      return _saveFetchData(command);
    } else if (command is GetSelectedDataCommand) {
      return _getSelectedData(command);
    } else if (command is GetDataChunkCommand) {
      return _getDataChunk(command);
    } else if (command is GetPageChunkCommand) {
      return _getPageChunk(command);
    } else if (command is DeleteProviderDataCommand) {
      return _deleteDataProviderData(command);
    } else if (command is GetMetaDataCommand) {
      return _getMetaData(command);
    } else if (command is DeleteRowCommand) {
      return _deleteRow(command);
    }

    return [];
  }

  Future<List<BaseCommand>> _deleteRow(DeleteRowCommand command) async {
    // set selected row of databook
    bool success = IDataService().deleteRow(
      pDataProvider: command.dataProvider,
      pDeletedRow: command.deletedRow,
      pNewSelectedRow: command.newSelectedRow,
    );

    // Notify components that their selected row changed, if setting the row failed show error dialog.
    if (success) {
      IUiService().notifyDataChange(
        pDataProvider: command.dataProvider,
      );
    } else {
      return [
        OpenErrorDialogCommand(
          message: FlutterUI.translate("Deleting row failed"),
          reason: "Could not delete the row locally",
        )
      ];
    }
    return [];
  }

  Future<List<BaseCommand>> _getMetaData(GetMetaDataCommand command) async {
    bool needFetch = IDataService().getDataBook(command.dataProvider) == null;

    if (needFetch) {
      return [
        FetchCommand(
          dataProvider: command.dataProvider,
          fromRow: -1,
          rowCount: 0,
          reason: "Fetch for ${command.runtimeType}",
          includeMetaData: true,
        )
      ];
    }

    DalMetaData metaData = IDataService().getMetaData(command.dataProvider)!;

    IUiService().sendSubsMetaData(
      pSubId: command.subId,
      pDataProvider: command.dataProvider,
      pMetaData: metaData,
    );

    return [];
  }

  Future<List<BaseCommand>> _deleteDataProviderData(DeleteProviderDataCommand command) async {
    IDataService().deleteDataFromDataBook(
      pDataProvider: command.dataProvider,
      pFrom: command.fromIndex,
      pTo: command.toIndex,
      pDeleteAll: command.deleteAll,
    );

    return [];
  }

  Future<List<BaseCommand>> _saveMetaData(SaveMetaDataCommand pCommand) async {
    IDataService().updateMetaData(pChangedResponse: pCommand.response);

    IUiService().notifyMetaDataChange(
      pDataProvider: pCommand.response.dataProvider,
    );

    return [];
  }

  Future<List<BaseCommand>> _saveFetchData(SaveFetchDataCommand pCommand) async {
    IDataService().updateData(pCommand: pCommand);

    return [];
  }

  Future<List<BaseCommand>> _getSelectedData(GetSelectedDataCommand pCommand) async {
    bool needFetch = IDataService().getDataBook(pCommand.dataProvider) == null;

    if (needFetch) {
      return [
        FetchCommand(
          dataProvider: pCommand.dataProvider,
          fromRow: 0,
          rowCount: IUiService().getSubscriptionRowcount(pDataProvider: pCommand.dataProvider),
          reason: "Fetch for ${pCommand.runtimeType}",
          includeMetaData: true,
        )
      ];
    }

    // Get Data record - is null if databook has no selected row
    DataRecord? record = IDataService().getSelectedRowData(
      pColumnNames: pCommand.columnNames,
      pDataProvider: pCommand.dataProvider,
    );

    IUiService().sendSubsSelectedData(
      pSubId: pCommand.subId,
      pDataProvider: pCommand.dataProvider,
      pDataRow: record,
    );

    return [];
  }

  Future<List<BaseCommand>> _getDataChunk(GetDataChunkCommand command) async {
    bool needFetch = IDataService().databookNeedsFetch(
      pFrom: command.from,
      pTo: command.to,
      pDataProvider: command.dataProvider,
    );

    if (needFetch) {
      bool includeMetaData = IDataService().getDataBook(command.dataProvider) == null;

      DataBook? dataBook = IDataService().getDataBook(command.dataProvider);
      int fromRow = dataBook?.records.keys.maxOrNull ?? command.from;

      return [
        FetchCommand(
          fromRow: fromRow,
          rowCount: command.to != null ? command.to! - fromRow : -1,
          dataProvider: command.dataProvider,
          reason: "Fetch for ${command.runtimeType}",
          includeMetaData: includeMetaData,
        )
      ];
    }

    DataChunk dataChunk = IDataService().getDataChunk(
      pColumnNames: command.dataColumns,
      pFrom: command.from,
      pTo: command.to,
      pDataProvider: command.dataProvider,
    );

    IUiService().sendSubsDataChunk(
      pDataChunk: dataChunk,
      pDataProvider: command.dataProvider,
      pSubId: command.subId,
    );
    return [];
  }

  Future<List<BaseCommand>> _getPageChunk(GetPageChunkCommand command) async {
    DataChunk dataChunk = IDataService().getDataChunk(
      pFrom: command.from,
      pTo: command.to,
      pDataProvider: command.dataProvider,
      pPageKey: command.pageKey,
    );

    IUiService().sendSubsPageChunk(
      pDataChunk: dataChunk,
      pDataProvider: command.dataProvider,
      pSubId: command.subId,
      pPageKey: command.pageKey,
    );
    return [];
  }
}
