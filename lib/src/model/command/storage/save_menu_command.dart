import 'storage_command.dart';
import '../../menu/menu_model.dart';

class SaveMenuCommand extends StorageCommand {

  final MenuModel menu;

  SaveMenuCommand({
    required String reason,
    required this.menu
  }) : super(reason:  reason);
}