import 'dart:io';

import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../model/command/config/save_auth_key_command.dart';

class SaveAuthKeyCommandProcessor implements ICommandProcessor<SaveAuthKeyCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveAuthKeyCommand command) async {
    getApplicationDocumentsDirectory()
        .then((value) => File('${value.path}/auth.txt'))
        .then((value) => value.writeAsString(command.authKey));
    return [];
  }
}
