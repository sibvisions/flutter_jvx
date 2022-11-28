import '../base_command.dart';

/// BaseType of any command interacting with the [ILayoutService]
abstract class LayoutCommand extends BaseCommand {
  LayoutCommand({
    required super.reason,
    super.beforeProcessing,
    super.afterProcessing,
  });
}
