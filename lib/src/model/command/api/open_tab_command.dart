import 'api_command.dart';

class OpenTabCommand extends ApiCommand {
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

  OpenTabCommand({
    required this.componentName,
    required this.index,
    required String reason,
  }) : super(reason: reason);

  @override
  String get logString => "OpenTabCommand: componentName: $componentName, index: $index,  reason: $reason";
}
