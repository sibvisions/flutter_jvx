import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/i_api_request.dart';
import '../../../../isolate/isolate_message.dart';

/// Used to send [IApiRequest] to the APIs isolate to be executed
class ApiIsolateRequestMessage extends IsolateMessage<List<BaseCommand>> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The request to be executed
  final IApiRequest request;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiIsolateRequestMessage({required this.request});
}
