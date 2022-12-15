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

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_auth_key_command.dart';
import '../../../../config/config_service.dart';
import '../../i_command_processor.dart';

class SaveAuthKeyCommandProcessor implements ICommandProcessor<SaveAuthKeyCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveAuthKeyCommand command) async {
    await ConfigService().setAuthCode(command.authKey);
    return [];
  }
}
