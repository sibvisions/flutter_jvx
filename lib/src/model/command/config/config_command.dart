import '../base_command.dart';

abstract class ConfigCommand extends BaseCommand {
  ConfigCommand({
    required String reason,
  }) : super(reason: reason);
}
