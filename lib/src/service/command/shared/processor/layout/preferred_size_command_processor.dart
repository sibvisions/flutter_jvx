import 'package:flutter_client/src/mixin/layout_service_mixin.dart';

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/layout/preferred_size_command.dart';
import '../../i_command_processor.dart';

class PreferredSizeCommandProcessor with LayoutServiceGetterMixin implements ICommandProcessor<PreferredSizeCommand> {
  @override
  Future<List<BaseCommand>> processCommand(PreferredSizeCommand command) {
    return getLayoutService().reportPreferredSize(pLayoutData: command.layoutData);
  }
}
