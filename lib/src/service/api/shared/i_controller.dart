import '../../../model/response/api_response.dart';
import '../../../model/command/base_command.dart';

abstract class IController {
  /// Process a list of [ApiResponse] into a list of [BaseCommand]s
  List<BaseCommand> processResponse({required List<ApiResponse> responses});

// /// Processes downloads, of images and translations
// List<BaseCommand> processDownload({required IApiRequest downloadRequest});
}
