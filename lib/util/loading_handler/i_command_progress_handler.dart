import 'package:flutter_client/src/model/command/base_command.dart';

abstract class ICommandProgressHandler {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Notifies the handler that this command is starting to be processed.
  void notifyCommandProgressStart(BaseCommand pCommand);

  /// Notifies the handler that this command is finished processing.
  void notifyCommandProgressEnd(BaseCommand pCommand);
}
