import 'package:flutter_client/src/layout/i_layout.dart';
import 'package:flutter_client/src/model/command/layout/layout_command.dart';

class RegisterParentCommand extends LayoutCommand{
  String parentId;
  List<String> childrenIds;
  ILayout layout;

  RegisterParentCommand({
    required this.layout,
    required this.childrenIds,
    required this.parentId,
    required String reason,
  }) : super(reason: reason);

}