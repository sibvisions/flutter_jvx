import '../../../../services.dart';
import '../base_command.dart';

/// BaseType of any command interacting with the [IStorageService]
abstract class StorageCommand extends BaseCommand {
  StorageCommand({
    required super.reason,
    super.beforeProcessing,
    super.afterProcessing,
    super.showLoading,
  });
}
