import 'package:flutter_client/src/model/command/api/api_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';

///
/// Interface for command Processing
///
abstract class ICommandProcessor<T extends BaseCommand> {

  Future<List<BaseCommand>> processCommand(T command);
}