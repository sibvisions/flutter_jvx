import 'package:flutter_client/src/mixin/layout_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/layout/register_parent_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class RegisterParentProcessor with LayoutServiceMixin implements ICommandProcessor<RegisterParentCommand> {
  @override
  Future<List<BaseCommand>> processCommand(RegisterParentCommand command) async {
    return layoutService.registerAsParent(
        pId: command.parentId,
        pChildrenIds: command.childrenIds,
        pLayout: command.layout,
        pLayoutData: command.layoutData,
        pConstraints: command.constraints
    );
  }

}