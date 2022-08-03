import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class SessionExpiredResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Message of the expired session
  final String? message;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SessionExpiredResponse({
    required this.message,
    required String name,
    required Object originalRequest,
  }) : super(name: name, originalRequest: originalRequest);

  SessionExpiredResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : message = pJson[ApiObjectProperty.message],
        super.fromJson(pJson: pJson, originalRequest: originalRequest);
}