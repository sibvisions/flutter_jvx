import 'package:flutter_client/src/model/command/base_command.dart';

///
/// All Services send Commands to to this Service which will call other Services in it's stead.
///
abstract class ICommandService {

  /// must check for all possible commands and process them accordingly.
  sendCommand(BaseCommand command);
}