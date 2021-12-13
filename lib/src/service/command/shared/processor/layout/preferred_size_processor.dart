import 'package:flutter_client/src/mixin/layout_service_mixin.dart';
import 'package:flutter_client/src/model/command/layout/preferred_size_command.dart';

import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class PreferredSizeProcessor with LayoutServiceMixin implements ICommandProcessor<PreferredSizeCommand>{

  @override
  Future<List<BaseCommand>> processCommand(PreferredSizeCommand command) async {
    return layoutService.registerPreferredSize(command.componentId, command.parentId, command.layoutData);
  }

}