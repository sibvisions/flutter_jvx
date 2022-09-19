import '../../model/command/base_command.dart';
import '../service.dart';

/// Defines the base construct of a [ICommandService]
/// Command service is used to facilitate communication between different services.
/// The Command Service is the only service to explicitly call other services.
abstract class ICommandService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  factory ICommandService() => services<ICommandService>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Process the incoming [BaseCommand].
  Future<void> sendCommand(BaseCommand command);
}
