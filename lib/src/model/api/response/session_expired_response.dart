import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';

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
    required String name
  }) : super(name: name);

  SessionExpiredResponse.fromJson({required Map<String, dynamic> pJson}) :
    message = pJson[ApiObjectProperty.message],
    super.fromJson(pJson);

}