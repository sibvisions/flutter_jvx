import '../base_command.dart';

/// BaseType of any command interacting with the [IConfigService]
abstract class ConfigCommand extends BaseCommand {
  ConfigCommand({
    required super.reason,
    super.beforeProcessing,
    super.afterProcessing,
  });
}
