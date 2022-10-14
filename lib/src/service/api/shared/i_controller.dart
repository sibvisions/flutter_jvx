import '../../../model/api_interaction.dart';
import '../../../model/command/base_command.dart';

abstract class IController {
  /// Process an [ApiInteraction] into a list of [BaseCommand]s
  List<BaseCommand> processResponse(ApiInteraction apiInteraction);
}
