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
import 'package:flutter/widgets.dart';

import '../../flutter_ui.dart';
import '../../mask/work_screen/work_screen.dart';
import '../../model/component/panel/fl_panel_model.dart';
import '../../service/storage/i_storage_service.dart';
import '../../service/ui/i_ui_service.dart';
import 'menu_location.dart';

class WorkScreenLocation extends BeamLocation<BeamState> {
  GlobalKey<WorkScreenState> key = GlobalKey();

  String? lastWorkscreen;
  String? lastId;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    FlutterUI.logUI.d("Building the workscreen location");

    if (context.beamingHistory.every((element) => element is WorkScreenLocation)) {
      context.beamingHistory.insert(0, MenuLocation());
    }

    final String workScreenName = state.pathParameters['workScreenName']!;
    FlPanelModel? model = IStorageService().getComponentByName(pComponentName: workScreenName) as FlPanelModel?;

    if (workScreenName != lastWorkscreen) {
      key = GlobalKey();
    } else if (model?.id != lastId) {
      key.currentState?.rebuild();
    }

    IUiService().getAppManager()?.onScreenPage();

    lastWorkscreen = workScreenName;
    lastId = model?.id;

    return [
      BeamPage(
        title: model?.screenTitle ?? FlutterUI.translate("Workscreen"),
        key: ValueKey(workScreenName),
        child: WorkScreen(
          key: key,
          screenName: workScreenName,
        ),
      )
    ];
  }

  @override
  List<Pattern> get pathPatterns => [
        '/workScreen',
        '/workScreen/:workScreenName',
      ];
}
