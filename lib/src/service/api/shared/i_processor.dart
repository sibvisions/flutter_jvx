import '../../../model/command/base_command.dart';

abstract class IProcessor {
  List<BaseCommand> processResponse(dynamic json);
}