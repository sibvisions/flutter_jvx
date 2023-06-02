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

class SelectRecordCommand extends SessionCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data provider to change selected row of
  final String dataProvider;

  /// The filter to identify the record.
  final Filter? filter;

  /// The selected row to shortcut the filter.
  /// This row index will be checked if the filter applies, otherwise checks every row until the filter applies.
  final int? rowNumber;

  /// The column to select. Null -> no column selection.
  final String? selectedColumn;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SelectRecordCommand({
    required super.reason,
    required this.dataProvider,
    this.rowNumber,
    this.filter,
    this.selectedColumn,
  }) : assert(filter != null || rowNumber == -1,
            "A filter must be provided except to deselect. Selected row must be -1 to deselect or use .deselect()");

  SelectRecordCommand.select({
    required super.reason,
    required this.dataProvider,
    required this.filter,
    this.rowNumber,
    this.selectedColumn,
  });

  SelectRecordCommand.deselect({
    required super.reason,
    required this.dataProvider,
  })  : rowNumber = -1,
        filter = null,
        selectedColumn = null;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "SelectRecordCommand{rowNumber: $rowNumber, dataProvider: $dataProvider, filter: $filter, ${super.toString()}}";
  }
}
