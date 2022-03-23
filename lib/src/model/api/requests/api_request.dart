/// Base class for all outgoing api requests
abstract class ApiRequest {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Converts request to json
  Map<String, dynamic> toJson();
}