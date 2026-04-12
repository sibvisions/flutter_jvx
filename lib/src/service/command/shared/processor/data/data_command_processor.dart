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

import 'package:collection/collection.dart';

import '../../../../../flutter_ui.dart';
import '../../../../../model/command/api/fetch_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/data_command.dart';
import '../../../../../model/command/data/delete_provider_data_command.dart';
import '../../../../../model/command/data/get_data_chunk_command.dart';
import '../../../../../model/command/data/get_meta_data_command.dart';
import '../../../../../model/command/data/get_page_chunk_command.dart';
import '../../../../../model/command/data/get_selected_data_command.dart';
import '../../../../../model/command/data/save_fetch_data_command.dart';
import '../../../../../model/command/data/save_meta_data_command.dart';
import '../../../../../model/data/data_book.dart';
import '../../../../../model/data/subscriptions/data_chunk.dart';
import '../../../../../model/data/subscriptions/data_record.dart';
import '../../../../../util/jvx_logger.dart';
import '../../../../data/i_data_service.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

/// Handles all [DataCommand]s.
class DataCommandProcessor extends ICommandProcessor<DataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DataCommand command, BaseCommand? origin) async {
    if (FlutterUI.logCommand.cl(Lvl.d)) {
      FlutterUI.logCommand.d("Execute data command ${command.runtimeType}");
    }

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
      subId: command.subId!,
      dataProvider: command.dataProvider,
      metaData: metaData,
    );

    return [];
  }

  Future<List<BaseCommand>> _deleteDataProviderData(DeleteProviderDataCommand command) async {
    IDataService().deleteDataFromDataBook(
      dataProvider: command.dataProvider,
      from: command.from,
      to: command.to,
      deleteAll: command.deleteAll,
    );

    return [];
  }

  Future<List<BaseCommand>> _saveMetaData(SaveMetaDataCommand command) async {
    IDataService().updateMetaData(changedResponse: command.response);

    IUiService().notifyMetaDataChange(command.response.dataProvider);

    return [];
  }

  Future<List<BaseCommand>> _saveFetchData(SaveFetchDataCommand command) async {
    await IDataService().updateFromFetch(command: command);

    return [];
  }

  Future<List<BaseCommand>> _getSelectedData(GetSelectedDataCommand command) async {
    bool needFetch = IDataService().getDataBook(command.dataProvider) == null;

    if (needFetch) {
      return [
        FetchCommand(
          dataProvider: command.dataProvider,
          fromRow: 0,
          rowCount: IUiService().getSubscriptionRowCount(command.dataProvider),
          reason: "Fetch for ${command.runtimeType}",
          includeMetaData: true,
        )
      ];
    }

    // Get Data record - is null if data book has no selected row
    DataRecord? record = IDataService().getSelectedRowData(
      columnNames: command.columnNames,
      dataProvider: command.dataProvider,
    );

    IUiService().sendSubsSelectedData(
      subId: command.subId!,
      dataProvider: command.dataProvider,
      dataRow: record,
    );

    return [];
  }

  Future<List<BaseCommand>> _getDataChunk(GetDataChunkCommand command) async {
    bool needFetch = IDataService().dataBookNeedsFetch(
      from: command.from!,
      to: command.to,
      dataProvider: command.dataProvider,
    );

    if (needFetch) {
      bool includeMetaData = IDataService().getDataBook(command.dataProvider) == null;

      DataBook? dataBook = IDataService().getDataBook(command.dataProvider);
      int fromRow = dataBook?.records.keys.maxOrNull ?? command.from!;

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
      columnNames: command.dataColumns,
      from: command.from!,
      to: command.to,
      dataProvider: command.dataProvider,
      fromStart : command.fromStart
    );

    IUiService().sendSubsDataChunk(
      dataChunk: dataChunk,
      dataProvider: command.dataProvider,
      subId: command.subId!,
    );
    return [];
  }

  Future<List<BaseCommand>> _getPageChunk(GetPageChunkCommand command) async {
    DataChunk dataChunk = IDataService().getDataChunk(
      from: command.from!,
      to: command.to,
      dataProvider: command.dataProvider,
      pageKey: command.pageKey,
    );

    IUiService().sendSubsPageChunk(
      dataChunk: dataChunk,
      dataProvider: command.dataProvider,
      subId: command.subId!,
      pageKey: command.pageKey,
    );
    return [];
  }
}
