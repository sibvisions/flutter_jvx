import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/work_screen/work_screen.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/component/panel/fl_panel_model.dart';

class WorkScreenLocation extends BeamLocation<BeamState> with UiServiceMixin {


  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    uiService.setRouteContext(pContext: context);

    final String workScreenId = state.pathParameters['workScreenId']!;

    FlPanelModel model = uiService.getComponentModel(pComponentId: workScreenId) as FlPanelModel;


    return [
      BeamPage(
        child: WorkScreen(screenModel: model),
        key: ValueKey("Work_$workScreenId}")
      )
    ];
  }

  @override
  List<Pattern> get pathPatterns => [
    '/workScreen',
    '/workScreen/:workScreenId'
  ];

}