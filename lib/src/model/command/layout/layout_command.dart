import 'package:flutter_client/src/model/command/base_command.dart';

abstract class LayoutCommand extends BaseCommand {
  LayoutCommand({
    required String reason
  }) : super(reason: reason);
}