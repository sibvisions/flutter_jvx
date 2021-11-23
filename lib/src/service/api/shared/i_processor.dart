import 'package:flutter_client/src/model/command/base_command.dart';

abstract class IProcessor {
  List<BaseCommand> processResponse(dynamic json);
}