import '../base_command.dart';

/// BaseType of any command interacting with the [IDataService]
abstract class DataCommand extends BaseCommand {
  DataCommand({
    required super.reason,
    super.beforeProcessing,
    super.afterProcessing,
    super.showLoading,
  });
}
