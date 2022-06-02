import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/components_factory.dart';
import 'package:flutter_client/src/mask/work_screen/work_screen.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/component/panel/fl_panel_model.dart';
import 'package:flutter_client/src/model/custom/custom_header.dart';
import 'package:flutter_client/src/model/custom/custom_screen.dart';

class WorkScreenLocation extends BeamLocation<BeamState> with UiServiceMixin {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final String workScreenName = state.pathParameters['workScreenName']!;
    FlPanelModel? model = uiService.getOpenScreen(pScreenName: workScreenName);

    // Header
    CustomHeader? header;
    // Footer
    Widget? footer;
    // Title displayed on the top
    String screenTitle = "SHOULD NEVER SHOW";
    // Screen Widget
    Widget screen = const Text("ERROR");

    bool isCustomScreen = false;

    if (model != null) {
      screen = ComponentsFactory.buildWidget(model);
      screenTitle = model.name;
    }

    // Custom Config for this screen
    CustomScreen? customScreen = uiService.getCustomScreen(pScreenName: workScreenName);

    if (customScreen != null) {
      header = customScreen.headerFactory?.call();
      footer = customScreen.footerFactory?.call();

      Widget? replaceScreen = customScreen.screenFactory?.call();
      if (replaceScreen != null) {
        isCustomScreen = true;
        screen = replaceScreen;
      }

      String? customTitle = customScreen.screenTitle;
      if (customTitle != null) {
        screenTitle = customTitle;
      }
    }

    return [
      BeamPage(
          child: WorkScreen(
            isCustomScreen: isCustomScreen,
            screenTitle: screenTitle,
            screenWidget: screen,
            footer: footer,
            header: header,
            screenName: workScreenName,
          ),
          key: ValueKey("Work_$workScreenName}"))
    ];
  }

  @override
  List<Pattern> get pathPatterns => [
        '/workScreen',
        '/workScreen/:workScreenName',
      ];
}
