import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../../components/components_factory.dart';
import '../../mask/work_screen/work_screen.dart';
import '../../mixin/ui_service_mixin.dart';
import '../../model/component/panel/fl_panel_model.dart';
import '../../model/custom/custom_header.dart';
import '../../model/custom/custom_screen.dart';

class WorkScreenLocation extends BeamLocation<BeamState> with UiServiceGetterMixin {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final String workScreenName = state.pathParameters['workScreenName']!;
    FlPanelModel? model = getUiService().getOpenScreen(pScreenName: workScreenName);

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
      screenTitle = model.screenTitle!;
    }

    // Custom Config for this screen
    CustomScreen? customScreen = getUiService().getCustomScreen(pScreenName: workScreenName);

    if (customScreen != null) {
      header = customScreen.headerFactory?.call(context);
      footer = customScreen.footerFactory?.call(context);

      Widget? replaceScreen = customScreen.screenFactory?.call(context);
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
        key: UniqueKey(),
      )
    ];
  }

  @override
  List<Pattern> get pathPatterns => [
        '/workScreen',
        '/workScreen/:workScreenName',
      ];
}
