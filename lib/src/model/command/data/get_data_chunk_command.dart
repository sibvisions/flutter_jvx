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

import 'package:rxdart/rxdart.dart';

import '../../data/subscriptions/data_subscription.dart';
import 'dataprovider_data_command.dart';

/// The command to get a data chunk (from cache).
class GetDataChunkCommand extends DataProviderDataCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// List of names of the dataColumns that are being requested
  final List<String>? dataColumns;

  /// Whether fresh data was fetched again from remote (=row 0)
  final bool fromStart;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  GetDataChunkCommand({
    required super.dataProvider,
    required super.subId,
    this.dataColumns,
    required super.from,
    super.to,
    this.fromStart = false,
    required super.reason,
    super.showLoading,
  }) : assert(subId != null), assert(from != null);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "GetDataChunkCommand{dataColumns: $dataColumns, fromStart: $fromStart, ${super.toString()}}";
  }
}
