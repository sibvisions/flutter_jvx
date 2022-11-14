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

  bool isNavigating = false;
  bool isForced = false;

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
            void completeNavigation() {
              isForced = false;
              isNavigating = false;
            }

            if (isNavigating) {
              return false;
            }

            isNavigating = true;

            return IUiService().saveAllEditors(null, "Closing Screen").then<bool>(
              (_) {
                if (IUiService().usesNativeRouting(pScreenLongName: screenLongName)) {
                  completeNavigation();
                  return true;
                } else {
                  Future commandFuture;
                  if (isForced) {
                    commandFuture = ICommandService()
                        .sendCommand(CloseScreenCommand(
                          reason: "Work screen back",
                          screenName: workScreenName,
                        ))
                        .then((value) => IUiService().sendCommand(
                              DeleteScreenCommand(
                                reason: "Work screen back",
                                screenName: workScreenName,
                              ),
                            ));
                  } else {
                    commandFuture = ICommandService().sendCommand(
                      NavigationCommand(
                        reason: "Back button pressed",
                        openScreen: workScreenName,
                      ),
                    );
                  }
                  commandFuture.catchError(IUiService().handleAsyncError).whenComplete(completeNavigation);
                  return false;
                }
              },
            ).catchError(
              (error, stacktrace) {
                completeNavigation();
                IUiService().handleAsyncError(error, stacktrace);
                return false;
              },
            );
          },
          child: Frame.wrapWithFrame(
            forceWeb: IConfigService().isWebOnly(),
            forceMobile: IConfigService().isMobileOnly(),
            builder: (context) => WorkScreen(
              key: key,
              screenName: workScreenName,
              onBackFunction: _back,
            ),
          ),
        ),
      )
    ];
  }

  Future<void> _back(BuildContext context, [bool pForced = false]) async {
    if (isNavigating) {
      return;
    }

    isForced = pForced;

    if (!(await Navigator.of(context).maybePop())) {
      context.beamBack();
    }
  }

  @override
  List<Pattern> get pathPatterns => [
        '/workScreen',
        '/workScreen/:workScreenName',
      ];
}
