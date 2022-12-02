import 'ui_command.dart';

/// Command to update components.
class UpdateComponentsCommand extends UiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// List of components whose model changed
  final List<String> changedComponents;

  /// List of components to delete
  final Set<String> deletedComponents;

  /// The affected component models.
  final Set<String> affectedComponents;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UpdateComponentsCommand({
    this.affectedComponents = const {},
    this.changedComponents = const [],
    this.deletedComponents = const {},
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "UpdateComponentsCommand{changedComponents: $changedComponents, deletedComponents: $deletedComponents, affectedComponents: $affectedComponents, ${super.toString()}}";
  }
}
