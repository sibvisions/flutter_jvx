import '../../../service/ui/i_ui_service.dart';
import '../base_command.dart';

///
/// BaseType of any Command interacting with the [IUiService]
///
abstract class UiCommand extends BaseCommand {
  UiCommand({
    required String reason,
  }) : super(reason: reason);
}
