import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../../../custom/custom_screen.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../components/components_factory.dart';
import '../../mask/work_screen/work_screen.dart';
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

    // Custom Config for this screen
    CustomScreen? customScreen = getUiService().getCustomScreen(pScreenName: workScreenName);

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
