import 'layout_command.dart';

class RegisterParentCommand extends LayoutCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The parent id.
  String parentId;

  /// List of children ids.
  List<String> childrenIds;

  /// The layout of this container.
  String layout;

  /// Additional layout data e.g. Anchors in form-layout
  String? layoutData;

  /// Constraints of this layout in relation of other layouts.
  String? constraints;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  RegisterParentCommand({
    required this.layout,
    required this.childrenIds,
    required this.parentId,
    this.layoutData,
    this.constraints,
    required String reason,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString =>
      "RegisterParentCommand | Component: $parentId | Childrens: ${childrenIds.toString()} | Reason $reason";
}
