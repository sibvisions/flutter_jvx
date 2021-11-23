import 'package:flutter_client/src/model/command/storage/storage_command.dart';
import 'package:flutter_client/src/model/menu/menu_model.dart';

class SaveMenuCommand extends StorageCommand {

  final MenuModel menu;

  SaveMenuCommand({
    required String reason,
    required this.menu
  }) : super(reason:  reason);
}