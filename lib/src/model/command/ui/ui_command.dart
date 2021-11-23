import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';


///
/// BaseType of any Command interacting with the [IUiService]
///
abstract class UiCommand extends BaseCommand {

  UiCommand({
    required String reason,
  }) : super(reason: reason);
}