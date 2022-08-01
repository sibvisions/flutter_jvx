import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../../../mixin/command_service_mixin.dart';
import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../mask/menu/app_menu.dart';
import '../../util/loading_handler/default_loading_progress_handler.dart';

/// Displays all possible screens of the menu
class MenuLocation extends BeamLocation<BeamState>
    with ConfigServiceGetterMixin, UiServiceGetterMixin, CommandServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    if (mounted) {
      getUiService().setRouteContext(pContext: context);
    }

    DefaultLoadingProgressHandler.setEnabled(!getConfigService().isOffline());

    return [
      BeamPage(child: AppMenu(), key: UniqueKey()),
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/menu'];
}
