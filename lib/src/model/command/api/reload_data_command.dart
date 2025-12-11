/*
 * Copyright 2025 SIB Visions GmbH
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
import 'dal_command.dart';

/// The command for reloading data provider.
class ReloadDataCommand extends DalCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Filter of this fetch. This is only used for tree/page fetches.
  /// For normal fetches, the filter is should be set with [FilterCommand]
  final Filter? filter;

  /// The row number to start fetching from.
  final int fromRow;

  /// The row count to fetch.
  final int rowCount;

  /// Whether we don't need records in the response
  final bool withoutFetch;

  /// If `true`, the root key will be set. Client side only.
  final bool setRootKey;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ReloadDataCommand({
    required super.dataProvider,
    this.fromRow = 0,
    this.rowCount = 0,
    this.withoutFetch = false,
    this.filter,
    this.setRootKey = false,
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
    return "fromRow: $fromRow, rowCount: $rowCount, withoutFetch: $withoutFetch, "
           "filter: $filter, setRootKey: $setRootKey, ${super.propertiesAsString()}";
  }
}
