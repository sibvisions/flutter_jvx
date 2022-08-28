import '../../model/command/base_command.dart';

abstract class ICommandProgressHandler {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Notifies the handler that this command is starting to be processed.
  void notifyProgressStart(BaseCommand pCommand);

  /// Notifies the handler that this command is finished processing.
  void notifyProgressEnd(BaseCommand pCommand);
}
