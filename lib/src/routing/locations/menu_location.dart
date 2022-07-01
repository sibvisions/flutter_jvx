import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/menu/app_menu.dart';
import 'package:flutter_client/src/mixin/command_service_mixin.dart';
import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/service/command/impl/command_service.dart';
import 'package:flutter_client/util/extensions/list_extensions.dart';
import 'package:flutter_client/util/loading_handler/loading_progress.dart';

/// Displays all possible screens of the menu
class MenuLocation extends BeamLocation<BeamState> with UiServiceGetterMixin, CommandServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    getUiService().setRouteContext(pContext: context);

    DefaultLoadingProgressHandler? loadingProgressHandler = (commandService as CommandService)
        .progressHandler
        .firstWhereOrNull((element) => element is DefaultLoadingProgressHandler) as DefaultLoadingProgressHandler?;
    loadingProgressHandler?.isEnabled = true;

    return [
      BeamPage(child: AppMenu(), key: const ValueKey("menu")),
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/menu'];
}
