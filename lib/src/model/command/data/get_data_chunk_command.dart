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

import '../../data/subscriptions/data_subscription.dart';
import 'data_command.dart';

class GetDataChunkCommand extends DataCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Id of the [DataSubscription] requesting data
  final String subId;

  /// Link to the dataBook containing the data
  final String dataProvider;

  /// List of names of the dataColumns that are being requested
  final List<String>? dataColumns;

  /// From which index data is being requested
  final int from;

  /// To which index data is being requested
  final int? to;

  /// True if the the data should only overwrite old existing data
  final bool isUpdate;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  GetDataChunkCommand({
    required this.dataProvider,
    required this.from,
    required this.subId,
    this.isUpdate = false,
    this.to,
    this.dataColumns,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "GetDataChunkCommand{subId: $subId, dataProvider: $dataProvider, dataColumns: $dataColumns, from: $from, to: $to, isUpdate: $isUpdate, ${super.toString()}}";
  }
}
