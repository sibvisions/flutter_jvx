import 'config_command.dart';

class SaveAuthKeyCommand extends ConfigCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Auth key to be saved
  final String authKey;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SaveAuthKeyCommand({
    required this.authKey,
    required String reason,
  }) : super(reason: reason);

  @override
  String get logString => "SaveAuthKeyCommand: authKey: $authKey, reason: $reason";
}
