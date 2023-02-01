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
typedef OnReloadCallback = int Function(int selectedRow);
typedef OnPageCallback = void Function(String pageKey, DataChunk dataChunk);

/// Used for subscribing in [IUiService] to potentially receive data.
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

  /// Callback will be called with selected row, regardless if only the selected row was fetched
  final OnSelectedRecordCallback? onSelectedRecord;

  /// Index from which data will be fetched, set to -1 to only receive the selected row
  int from;

  /// Index to which data will be fetched, if null - will return all data from provider, will fetch if necessary
  int? to;

  /// Callback will only be called with [DataChunk] if from is not -1.
  final OnDataChunkCallback? onDataChunk;

  /// Callback will be called with metaData of requested dataBook
  final OnMetaDataCallback? onMetaData;

  /// Callback will be called when a reload happens. Return value is the new subscription count.
  final OnReloadCallback? onReload;

  /// Callback will be called when a page is fetched.
  final OnPageCallback? onPage;

  /// List of column names which should be fetched, return order will correspond to order of this list
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
    this.onReload,
    this.onPage,
    this.to,
    this.dataColumns,
  }) : id = getRandomString(15);

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
