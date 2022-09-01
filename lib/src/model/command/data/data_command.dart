import '../base_command.dart';

abstract class DataCommand extends BaseCommand {
  DataCommand({
    required String reason,
  }) : super(reason: reason);
}
