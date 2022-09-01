import 'api_command.dart';

class CloseTabCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the tabset panel
  final String componentName;

  /// Index of the closed tab
  final int index;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CloseTabCommand({
    required this.componentName,
    required this.index,
    required super.reason,
  });

  @override
  String toString() {
    return 'CloseTabCommand{componentName: $componentName, index: $index, ${super.toString()}}';
  }
}
