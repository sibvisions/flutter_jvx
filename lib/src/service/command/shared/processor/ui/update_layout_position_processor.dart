import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_client/src/layout/split_layout.dart';

import '../../../../../mixin/ui_service_getter_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/update_layout_position_command.dart';
import '../../../../../model/layout/layout_data.dart';
import '../../i_command_processor.dart';

class UpdateLayoutPositionProcessor with UiServiceGetterMixin implements ICommandProcessor<UpdateLayoutPositionCommand> {
  @override
  Future<List<BaseCommand>> processCommand(UpdateLayoutPositionCommand command) {
    var uiService = getUiService();

    for (LayoutData element in command.layoutDataList) {
      if (element.layout is SplitLayout) {
        SplitLayout layout = element.layout as SplitLayout;
        log("${command.id}, --- split layout gets new layout: ${layout.secondComponentViewer.top}");
      }
      uiService.setLayoutPosition(layoutData: element);
    }

    return SynchronousFuture([]);
  }
}
