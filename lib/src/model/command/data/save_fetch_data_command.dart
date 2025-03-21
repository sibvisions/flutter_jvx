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
import '../../response/dal_fetch_response.dart';
import 'data_command.dart';

/// The command to save fetched records in cache.
class SaveFetchDataCommand extends DataCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Server response
  final DalFetchResponse response;

  /// The last filter used by a request. Filtered fetch responses do not represent the "whole" state. e.g. isAllFetched is ignored.
  /// As a filtered response usually does not represent "all" the data.
  final Filter requestFilter;

  /// Whether to set the root key
  final bool setRootKey;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SaveFetchDataCommand({
    required this.response,
    this.requestFilter = const Filter.empty(),
    this.setRootKey = false,
    required super.reason,
    super.showLoading,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overriden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "SaveFetchDataCommand{requestFilter: $requestFilter, response: $response, setRootKey: $setRootKey, ${super.toString()}}";
  }
}
