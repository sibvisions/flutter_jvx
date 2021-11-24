import '../base_command.dart';

///
/// Super class for all StorageCommands
///
abstract class StorageCommand extends BaseCommand {

  StorageCommand({
    required String reason
  }) : super(reason: reason);
}