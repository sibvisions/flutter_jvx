import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../mask/menu/app_menu.dart';
import '../../util/loading_handler/loading_progress_handler.dart';

/// Displays all possible screens of the menu
class MenuLocation extends BeamLocation<BeamState> with ConfigServiceGetterMixin, UiServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    LoadingProgressHandler.setEnabled(!getConfigService().isOffline());

    return [
      BeamPage(
        //Append state to trigger rebuild on online/offline switch
        key: ValueKey("Menu_${getConfigService().isOffline() ? "offline" : "online"}"),
        child: AppMenu(),
      ),
    ];
  }

  @override
  List<Pattern> get pathPatterns => [
        '/menu',
      ];
}
