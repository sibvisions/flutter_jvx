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

import 'package:beamer/beamer.dart';

import '../../../../../../flutter_ui.dart';
import '../../../../../../model/command/base_command.dart';
import '../../../../../../model/command/ui/route/route_to_work_command.dart';
import '../../../../../../routing/locations/main_location.dart';
import '../../../../../ui/i_ui_service.dart';
import '../../../i_command_processor.dart';

class RouteToWorkCommandProcessor extends ICommandProcessor<RouteToWorkCommand> {
  @override
  Future<List<BaseCommand>> processCommand(RouteToWorkCommand command, BaseCommand? origin) async {
    var lastBeamState = FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState;
    // Don't route if we are already there (can create history duplicates when using query parameters; e.g. in deep links)
    if (lastBeamState.pathParameters[MainLocation.screenNameKey] != command.screenName) {
      IUiService().routeToWorkScreen(pScreenName: command.screenName, pReplaceRoute: command.replaceRoute);
    }

    return [];
  }
}
