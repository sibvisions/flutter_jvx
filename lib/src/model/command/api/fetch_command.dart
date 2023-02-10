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

import '../../request/filter.dart';
import 'session_command.dart';

class FetchCommand extends SessionCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final List<String>? columnNames;

  final bool includeMetaData;

  final int fromRow;

  final int rowCount;

  final String dataProvider;

  /// If `true`, the data provider will be reloaded server side.
  bool reload;

  final Filter? filter;

  final bool setRootKey;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FetchCommand({
    required this.fromRow,
    required this.rowCount,
    required this.dataProvider,
    this.includeMetaData = false,
    this.columnNames,
    this.filter,
    this.setRootKey = false,
    this.reload = false,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "FetchCommand{columnNames: $columnNames, includeMetaData: $includeMetaData, fromRow: $fromRow, rowCount: $rowCount, dataProvider: $dataProvider, reload:$reload ${super.toString()}}";
  }
}
