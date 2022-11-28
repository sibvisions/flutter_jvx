import '../base_command.dart';

/// BaseType of any command interacting with the [IApiService]
abstract class ApiCommand extends BaseCommand {
  ApiCommand({
    required super.reason,
    super.beforeProcessing,
    super.afterProcessing,
    super.showLoading,
  });
}
