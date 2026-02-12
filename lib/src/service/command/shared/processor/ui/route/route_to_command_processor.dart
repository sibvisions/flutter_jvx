/*
 * Copyright 2023 SIB Visions GmbH
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

import '../../../../../../flutter_ui.dart';
import '../../../../../../model/command/base_command.dart';
import '../../../../../../model/command/ui/route/route_to_command.dart';
import '../../../i_command_processor.dart';

class RouteToCommandProcessor extends ICommandProcessor<RouteToCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(RouteToCommand command, BaseCommand? origin) async {
    if (command.replaceRoute) {
      FlutterUI.getBeamerDelegate().beamToReplacementNamed(command.uri);
    } else {
      FlutterUI.getBeamerDelegate().beamToNamed(command.uri);
    }

    return [];
  }
}
