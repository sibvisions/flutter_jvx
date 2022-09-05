import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../../custom/custom_screen.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../components/components_factory.dart';
import '../../mask/frame/frame.dart';
import '../../mask/work_screen/work_screen.dart';
import '../../model/command/api/navigation_command.dart';
import '../../model/component/panel/fl_panel_model.dart';

class WorkScreenLocation extends BeamLocation<BeamState> with UiServiceGetterMixin {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final String workScreenName = state.pathParameters['workScreenName']!;
    FlPanelModel? model = getUiService().getComponentByName(pComponentName: workScreenName) as FlPanelModel?;

    // Header
    PreferredSizeWidget? header;
    // Footer
    Widget? footer;
    // Title displayed on the top
    String screenTitle = "No Title";
    // Screen Widget
    Widget? screen;

    bool isCustomScreen = false;

    if (model != null) {
      screen = ComponentsFactory.buildWidget(model);
      screenTitle = model.screenTitle!;
    }

    String screenLongName = model?.screenLongName ?? workScreenName;

    // Custom Config for this screen
    CustomScreen? customScreen = getUiService().getCustomScreen(pScreenLongName: screenLongName);

    if (customScreen != null) {
      header = customScreen.headerBuilder?.call(context);
      footer = customScreen.footerBuilder?.call(context);

      Widget? replaceScreen = customScreen.screenBuilder?.call(context, screen);
      if (replaceScreen != null) {
        isCustomScreen = true;
        screen = replaceScreen;
      }

      String? customTitle = customScreen.screenTitle;
      if (customTitle != null) {
        screenTitle = customTitle;
      } else if (customScreen.menuItemModel != null) {
        screenTitle = customScreen.menuItemModel!.label;
      }
    }

    if (screen == null) {
      screen = Container();
      getUiService().routeToMenu(pReplaceRoute: true);
    }

    getUiService().getAppManager()?.onScreen();

    final GlobalKey childKey = GlobalKey();

    return [
      BeamPage(
        key: ValueKey(screenTitle),
        child: WillPopScope(
          onWillPop: () async {
            if (!getUiService().usesNativeRouting(pScreenLongName: screenLongName)) {
              unawaited(getUiService()
                  .sendCommand(NavigationCommand(reason: "Back button pressed", openScreen: workScreenName)));
              return false;
            }
            return true;
          },
          child: Frame.wrapWithFrame(
            childKey: childKey,
            child: WorkScreen(
              key: childKey,
              isCustomScreen: isCustomScreen,
              screenTitle: screenTitle,
              screenWidget: screen,
              footer: footer,
              header: header,
              screenName: workScreenName,
              screenLongName: screenLongName,
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
