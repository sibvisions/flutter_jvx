import 'package:flutter_client/src/layout/i_layout.dart';
import 'package:flutter_client/src/model/command/layout/layout_command.dart';

class RegisterParentCommand extends LayoutCommand{
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  /// The parent id.
  String parentId;

  /// List of children ids.
  List<String> childrenIds;

  /// The layout of this container.
  ILayout layout;
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  RegisterParentCommand({
    required this.layout,
    required this.childrenIds,
    required this.parentId,
    required String reason,
  }) : super(reason: reason);
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  @override
  String get logString => "RegisterParentCommand | Component: $parentId | Childrens: ${childrenIds.toString()} | Reason $reason";

}