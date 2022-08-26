import '../../../model/command/base_command.dart';

/// Defines the base construct of a [ICommandProcessor].
// Author: Michael Schober
abstract class ICommandProcessor<T extends BaseCommand> {
  /// Processes input [BaseCommand] and will return eventual resulting commands.
  Future<List<BaseCommand>> processCommand(T command);
}
