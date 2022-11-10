import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../../commands.dart';
import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../mask/frame/frame.dart';
import '../../mask/work_screen/work_screen.dart';
import '../../model/component/panel/fl_panel_model.dart';
import 'menu_location.dart';

class WorkScreenLocation extends BeamLocation<BeamState> {
  GlobalKey<WorkScreenState> key = GlobalKey();

  String? lastWorkscreen;
  String? lastId;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    FlutterJVx.logUI.d("Building the workscreen location");

    if (context.beamingHistory.every((element) => element is WorkScreenLocation)) {
      context.beamingHistory.insert(0, MenuLocation());
    }

    final String workScreenName = state.pathParameters['workScreenName']!;
    FlPanelModel? model = IUiService().getComponentByName(pComponentName: workScreenName) as FlPanelModel?;
    String screenLongName = model?.screenLongName ?? workScreenName;

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
        title: model?.screenTitle ?? FlutterJVx.translate("Workscreen"),
        key: ValueKey(workScreenName),
        child: WillPopScope(
          onWillPop: () async {
            if (!IUiService().usesNativeRouting(pScreenLongName: screenLongName)) {
              IUiService().saveAllEditorsThen(null, () {
                IUiService().sendCommand(NavigationCommand(reason: "Back button pressed", openScreen: workScreenName));
              }, "Closing screen");
              return false;
            }
            return true;
          },
          child: Frame.wrapWithFrame(
            forceWeb: IConfigService().isWebOnly(),
            forceMobile: IConfigService().isMobileOnly(),
            builder: (context) => WorkScreen(
              key: key,
              screenName: workScreenName,
            ),
          ),
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
