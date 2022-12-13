/* Copyright 2022 SIB Visions GmbH
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

import 'dart:collection';

import '../../../flutter_ui.dart';
import '../../../model/command/base_command.dart';
import '../../../model/data/column_definition.dart';
import '../../../model/data/data_book.dart';
import '../../../model/data/subscriptions/data_chunk.dart';
import '../../../model/data/subscriptions/data_record.dart';
import '../../../model/response/dal_fetch_response.dart';
import '../../../model/response/dal_meta_data_response.dart';
import '../i_data_service.dart';

class DataService implements IDataService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all DataBooks with dataProvider as key
  HashMap<String, DataBook> dataBooks = HashMap();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization",
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates an [DataService] Instance
  DataService.create();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void clear() {
    clearDataBooks();
  }

  @override
  Future<List<BaseCommand>> updateData({required DalFetchResponse pFetch}) async {
    DataBook? dataBook = dataBooks[pFetch.dataProvider];
    if (dataBook == null) {
      dataBook = DataBook.empty();
      dataBook.saveFromFetchRequest(pFetchResponse: pFetch);
      dataBooks[pFetch.dataProvider] = dataBook;
    } else {
      if (pFetch.clear) {
        dataBook.clearRecords();
      }
      dataBook.saveFromFetchRequest(pFetchResponse: pFetch);
    }

    return [];
  }

  @override
  Future<bool> updateMetaData({required DalMetaDataResponse pMetaData}) async {
    DataBook? dataBook = dataBooks[pMetaData.dataProvider];

    if (dataBook == null) {
      dataBook = DataBook(
        dataProvider: pMetaData.dataProvider,
        records: HashMap(),
        columnDefinitions: pMetaData.columns,
        isAllFetched: false,
        selectedRow: -1,
        columnViewTable: pMetaData.columnViewTable,
        metaData: pMetaData,
      );
      dataBooks[dataBook.dataProvider] = dataBook;
    } else {
      dataBook.columnDefinitions = pMetaData.columns;
      dataBook.columnViewTable = pMetaData.columnViewTable;
      dataBook.metaData = pMetaData;
    }

    return true;
  }

  @override
  Future<DataRecord?> getSelectedRowData({
    required List<String>? pColumnNames,
    required String pDataProvider,
  }) async {
    DataBook dataBook = dataBooks[pDataProvider]!;

    DataRecord? selectedRowColumnData = dataBook.getSelectedRecord(pDataColumnNames: pColumnNames);

    return selectedRowColumnData;
  }

  @override
  Future<DataChunk> getDataChunk({
    required int pFrom,
    required String pDataProvider,
    int? pTo,
    List<String>? pColumnNames,
  }) async {
    // Get data from all requested columns
    List<List<dynamic>> columnData = [];
    List<ColumnDefinition> columnDefinitions = [];

    DataBook dataBook = dataBooks[pDataProvider]!;

    // If pTo is null, all possible records are being requested
    pTo ??= dataBook.records.length;

    // Get data from databook and add column definitions in correct order -
    // either same as requested or as received from server
    if (pColumnNames != null) {
      for (String columnName in pColumnNames) {
        columnDefinitions.add(dataBook.columnDefinitions.firstWhere((element) => element.name == columnName));
        columnData.add(dataBook.getDataFromColumn(
          pColumnName: columnName,
          pFrom: pFrom,
          pTo: pTo,
        ));
      }
    } else {
      columnDefinitions.addAll(dataBook.columnDefinitions);

      for (ColumnDefinition colDef in columnDefinitions) {
        columnData.add(dataBook.getDataFromColumn(
          pColumnName: colDef.name,
          pFrom: pFrom,
          pTo: pTo,
        ));
      }
    }

    // Check if requested range of fetch is too long
    int fetchLength = pTo - pFrom;
    if (columnData[0].length < fetchLength) {
      fetchLength = columnData[0].length;
    }

    // Build rows out of column data
    HashMap<int, List<dynamic>> data = HashMap();
    for (int i = 0; i < fetchLength; i++) {
      List<dynamic> row = [];
      for (List d in columnData) {
        row.add(d[i]);
      }
      data[i + pFrom] = row;
    }

    return DataChunk(
      data: data,
      isAllFetched: dataBook.isAllFetched,
      columnDefinitions: columnDefinitions,
      from: pFrom,
      to: pTo,
    );
  }

  @override
  DalMetaDataResponse getMetaData({required String pDataProvider}) {
    DataBook dataBook = dataBooks[pDataProvider]!;
    return dataBook.metaData!;
  }

  @override
  Future<bool> checkIfFetchPossible({
    required int pFrom,
    required String pDataProvider,
    int? pTo,
  }) async {
    if (!dataBooks.containsKey(pDataProvider)) {
      return true;
    }

    DataBook dataBook = dataBooks[pDataProvider]!;

    // If all has already been fetched, then there is no point in fetching more,
    // If not all data is fetched and pTo is null (all possible data is being requested), more should be fetched
    if (dataBook.isAllFetched) {
      return false;
    } else if (pTo == null) {
      return true;
    }

    // Check all indexes if they are present.
    for (int i = pFrom; i < pTo; i++) {
      var record = dataBook.records[i];
      if (record == null) {
        return true;
      }
    }

    // Returns false if all needed rows are already fetched.
    return false;
  }

  @override
  Future<bool> deleteDataFromDataBook({
    required String pDataProvider,
    required int? pFrom,
    required int? pTo,
    required bool? pDeleteAll,
  }) async {
    // Get data book and return false if it does not exist
    DataBook? dataBook = dataBooks[pDataProvider];
    if (dataBook == null) {
      return false;
    }
    // If delete all flag is set just clear all records
    if (pDeleteAll == true) {
      dataBook.clearRecords();
      return true;
    }
    // Clear only records in given range
    if (pFrom != null && pTo != null) {
      dataBook.deleteRecordRange(pFrom: pFrom, pTo: pTo);
      return true;
    }
    return false;
  }

  @override
  bool setSelectedRow({
    required String pDataProvider,
    required int pNewSelectedRow,
  }) {
    // get databook, if null return false
    DataBook? dataBook = dataBooks[pDataProvider];
    if (dataBook == null) {
      return false;
    }
    // set selected row
    dataBook.selectedRow = pNewSelectedRow;
    return true;
  }

  @override
  int getSelectedRow(String pDataProvider) {
    DataBook? dataBook = dataBooks[pDataProvider];

    return dataBook?.selectedRow ?? -1;
  }

  @override
  Future<bool> deleteRow({
    required String pDataProvider,
    required int pDeletedRow,
    required int pNewSelectedRow,
  }) async {
    // get databook, if null return false
    DataBook? dataBook = dataBooks[pDataProvider];
    if (dataBook == null || dataBook.records.length <= pDeletedRow) {
      return false;
    }

    for (int i = pDeletedRow; i < dataBook.records.length - 1; i++) {
      dataBook.records[i] = dataBook.records[i + 1]!;
    }

    dataBook.records.remove(dataBook.records.length - 1);

    dataBook.selectedRow = pNewSelectedRow;

    return true;
  }

  @override
  void clearData(String pWorkscreen) {
    FlutterUI.logUI.i("Clearing all data books of prefix: $pWorkscreen");
    FlutterUI.logUI.i("Pre clearing: ${dataBooks.values}");
    dataBooks.removeWhere((key, value) => key.startsWith(pWorkscreen, key.indexOf("/") + 1));
    FlutterUI.logUI.i("Post clearing: ${dataBooks.values}");
  }

  @override
  void clearDataBooks() {
    return dataBooks.clear();
  }

  @override
  HashMap<String, DataBook> getDataBooks() {
    return HashMap.from(dataBooks);
  }

  @override
  DataBook? getDataBook(String pDataProvider) {
    return dataBooks[pDataProvider];
  }
}
