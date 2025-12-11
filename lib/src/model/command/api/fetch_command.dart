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

import '../../../service/data/i_data_service.dart';
import '../../request/filter.dart';
import 'filter_command.dart';
import 'dal_command.dart';

/// The command for record fetching.
class FetchCommand extends DalCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Filter of this fetch. This is only used for tree/page fetches.
  /// For normal fetches, the filter is should be set with [FilterCommand]
  final Filter? filter;

  /// If `true`, the meta data will be included.
  final bool includeMetaData;

  /// The row number to start fetching from.
  final int fromRow;

  /// The row count to fetch.
  final int rowCount;

  /// If `true`, the data provider will be reloaded server side.
  bool reload;

  /// If `true`, the root key will be set. Client side only.
  final bool setRootKey;

  /// Whether it's a fetch for going offline.
  final bool offline;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FetchCommand({
    required super.dataProvider,
    required this.fromRow,
    required this.rowCount,
    this.includeMetaData = false,
    this.filter,
    this.reload = false,
    this.setRootKey = false,
    this.offline = false,
    required super.reason,
    super.showLoading,
  }) {
    IDataService().setDataBookFetching(
      dataProvider,
      rowCount == -1 ? rowCount : fromRow + rowCount,
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String propertiesAsString() {
    return "fromRow: $fromRow, rowCount: $rowCount, includeMetaData: $includeMetaData, "
           "filter: $filter, reload:$reload, setRootKey: $setRootKey, offline: $offline, ${super.propertiesAsString()}";
  }

}
