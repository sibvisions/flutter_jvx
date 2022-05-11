import 'package:flutter_client/src/model/command/config/config_command.dart';

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
  // TODO: implement logString
  String get logString => throw UnimplementedError();
}
