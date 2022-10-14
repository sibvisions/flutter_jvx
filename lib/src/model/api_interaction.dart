import 'request/i_api_request.dart';
import 'response/api_response.dart';

class ApiInteraction<Resp extends ApiResponse, Req extends IApiRequest> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Request that provoked the [responses]
  final Req? request;

  /// Responses that resulted from the [request]
  final List<Resp> responses;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiInteraction({
    this.request,
    required this.responses,
  });

  @override
  String toString() {
    return 'ApiInteraction{request: $request, responses: $responses}';
  }
}
