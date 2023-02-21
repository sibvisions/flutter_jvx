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
import 'dart:collection';

import '../../model/command/base_command.dart';
import '../../model/command/data/save_fetch_data_command.dart';
import '../../model/data/data_book.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/response/dal_data_provider_changed_response.dart';
import '../../model/response/dal_meta_data_response.dart';
import '../service.dart';

/// Interface for a dataService meant to handle all dataBook related tasks,
abstract class IDataService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  factory IDataService() => services<IDataService>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Basically resets the service
  FutureOr<void> clear(bool pFullClear);

  /// Establishes the meta data of the given dataBook
  Future<bool> updateMetaData({required DalMetaDataResponse pChangedResponse});

  /// Establishes the meta data of the given dataBook
  Future<bool> setMetaData({required DalMetaData pMetaData});

  /// Updates parts of the meta data of a given dataBook
  bool updateMetaDataChangedRepsonse({required DalDataProviderChangedResponse pChangedResponse});

  /// Updates dataBook with fetched data,
  Future<List<BaseCommand>> updateData({required SaveFetchDataCommand pCommand});

  /// Updates parts of dataBook with changed data.
  bool updateDataChangedResponse({required DalDataProviderChangedResponse pChangedResponse});

  /// Updates parts of dataBook with new selection data.
  bool updateSelectionChangedResponse({required DalDataProviderChangedResponse pChangedResponse});

  /// Returns column data of the selected row of the dataProvider
  Future<DataRecord?> getSelectedRowData({
    required List<String>? pColumnNames,
    required String pDataProvider,
  });

  /// Returns [DataChunk],
  /// if [pColumnNames] is null will return all columns
  /// if [pTo] is null will return all rows
  Future<DataChunk> getDataChunk({
    required int pFrom,
    required String pDataProvider,
    int? pTo,
    List<String>? pColumnNames,
    String? pPageKey,
  });

  /// Returns the full [DalMetaDataResponse] for this dataProvider
  DalMetaData getMetaData({required String pDataProvider});

  /// Returns true if a fetch for the provided range is possible/necessary to fulfill requested range.
  Future<bool> checkIfFetchPossible({
    required String pDataProvider,
    required int pFrom,
    int? pTo,
  });

  /// Returns true when deletion was successful
  Future<bool> deleteDataFromDataBook({
    required String pDataProvider,
    required int? pFrom,
    required int? pTo,
    required bool? pDeleteAll,
  });

  /// Returns true when row selection was successful (dataProvider and dataRow exist)
  bool setSelectedRow({
    required String pDataProvider,
    required int pNewSelectedRow,
    String? pNewSelectedColumn,
  });

  /// Returns true when row selection was successful (dataProvider and dataRow exist)
  Future<bool> deleteRow({
    required String pDataProvider,
    required int pDeletedRow,
    required int pNewSelectedRow,
  });

  /// Clears all the databooks of this workscreen
  void clearData(String pWorkscreen);

  /// Clear all databooks
  void clearDataBooks();

  /// Gets all databooks
  HashMap<String, DataBook> getDataBooks();

  /// Gets a databook
  DataBook? getDataBook(String pDataProvider);
}
