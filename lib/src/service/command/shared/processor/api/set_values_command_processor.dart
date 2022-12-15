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

import '../../../../../model/command/api/set_values_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_set_values_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class SetValuesCommandProcessor implements ICommandProcessor<SetValuesCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SetValuesCommand command) {
    return IApiService().sendRequest(
      ApiSetValuesRequest(
        componentId: command.componentId,
        dataProvider: command.dataProvider,
        columnNames: command.columnNames,
        values: command.values,
        filter: command.filter,
        filterCondition: command.filterCondition,
      ),
    );
  }
}
