import '../../model/command/base_command.dart';

/// Defines the base construct of a [ICommandService]
/// Command service is used to facilitate communication between different services.
/// The Command Service is the only service to explicitly call other services.
// Author: Michael Schober
abstract class ICommandService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Process the incoming [BaseCommand].
  sendCommand(BaseCommand command);
}