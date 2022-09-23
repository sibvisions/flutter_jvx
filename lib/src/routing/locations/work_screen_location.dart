import 'dart:async';
import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../../custom/custom_screen.dart';
import '../../../services.dart';
import '../../components/components_factory.dart';
import '../../mask/frame/frame.dart';
import '../../mask/work_screen/work_screen.dart';
import '../../model/command/api/navigation_command.dart';
import '../../model/component/panel/fl_panel_model.dart';

class WorkScreenLocation extends BeamLocation<BeamState> {
  String lastWorkscreen = "";
  UniqueKey workscreenKey = UniqueKey();

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    log("Building the workscreen location");

    final String workScreenName = state.pathParameters['workScreenName']!;
    FlPanelModel? model = IUiService().getComponentByName(pComponentName: workScreenName) as FlPanelModel?;

    if (workScreenName != lastWorkscreen) {
      workscreenKey = UniqueKey();
      lastWorkscreen = workScreenName;
    }

    if (data != null && data is Map<String, dynamic> && (data as Map<String, dynamic>)["reload"] == true) {
      workscreenKey = UniqueKey();
    }

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
    CustomScreen? customScreen = IUiService().getCustomScreen(pScreenLongName: screenLongName);

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
      IUiService().routeToMenu(pReplaceRoute: true);
    }

    IUiService().getAppManager()?.onScreenPage();

    return [
      BeamPage(
        title: screenTitle,
        key: workscreenKey,
        child: WillPopScope(
          onWillPop: () async {
            if (!IUiService().usesNativeRouting(pScreenLongName: screenLongName)) {
              unawaited(IUiService()
                  .sendCommand(NavigationCommand(reason: "Back button pressed", openScreen: workScreenName)));
              return false;
            }
            return true;
          },
          child: Frame.wrapWithFrame(
            forceWeb: IConfigService().isWebOnly(),
            forceMobile: IConfigService().isMobileOnly(),
            builder: (context) => WorkScreen(
              isCustomScreen: isCustomScreen,
              screenTitle: screenTitle,
              screenWidget: screen!,
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
