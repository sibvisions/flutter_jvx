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

import 'dart:math';

import '../../../service/ui/i_ui_service.dart';
import '../data_book.dart';
import 'data_chunk.dart';
import 'data_record.dart';

typedef OnSelectedRecordCallback = void Function(DataRecord? dataRecord);
typedef OnDataChunkCallback = void Function(DataChunk dataChunk);
typedef OnMetaDataCallback = void Function(DalMetaData metaData);
typedef OnReloadCallback = int Function();
typedef OnPageCallback = void Function(String pageKey, DataChunk dataChunk);
typedef OnDataToDisplayMapChanged = void Function();

/// Used for subscribing in [IUiService] to receive data.
///
///
class DataSubscription {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Unique id of this subscription
  final String id;

  /// Reference to creator of this subscription
  final Object subbedObj;

  /// Data provider from which data will be fetched
  final String dataProvider;

  /// Callback will be called with selected row.
  final OnSelectedRecordCallback? onSelectedRecord;

  /// Index from which data will be fetched. Must be >= 0 if onDataChunk is not null
  int from;

  /// Index to which, excluding itself, data will be fetched.
  /// If null or -1 - will return all data from provider, will fetch all if necessary.
  ///
  /// [from] : 0; [to] : 0; will return no record.
  /// [from] : 0; [to] : 1; will return 1 record.
  ///
  int? to;

  /// Callback will only be called with [DataChunk] if from is not -1.
  final OnDataChunkCallback? onDataChunk;

  /// Callback will be called with metaData of requested dataBook
  final OnMetaDataCallback? onMetaData;

  /// Callback will be called when dataToDisplayMap changes
  final OnDataToDisplayMapChanged? onDataToDisplayMapChanged;

  /// Called with the selected row index of the data provider when it has been reloaded by the server.
  ///
  /// The return value of this function then acts as the new `to` of this subscription.
  /// E.g. A table which only subscribes `to` 100 records but always wants to at least subscribe to the selected should return max(100, selectedRow).
  /// Therefore this table will always adjust its subscription to the selected row.
  final OnReloadCallback? onReload;

  /// Callback will be called when a page is fetched.
  final OnPageCallback? onPage;

  /// Which columns to subscribe to.
  ///
  /// If null, all will be retrieved. Works for both onDataChunk and onSelectedRecord.
  /// The order of this list is important, as it will be used to determine the order of the data.
  List<String>? dataColumns;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DataSubscription({
    required this.subbedObj,
    required this.dataProvider,
    this.from = -1,
    this.onSelectedRecord,
    this.onDataChunk,
    this.onMetaData,
    this.onDataToDisplayMapChanged,
    this.onReload,
    this.onPage,
    this.to,
    this.dataColumns,
  })  : id = getRandomString(15),
        assert(onDataChunk == null || from != -1, "onDataChunk can only be used if from is not -1");

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  bool same(DataSubscription subscription) {
    if (subscription.subbedObj == subbedObj && subscription.dataProvider == dataProvider) {
      return true;
    }
    return false;
  }
}

const _chars = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
Random _rnd = Random();

String getRandomString(int length) =>
    String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
