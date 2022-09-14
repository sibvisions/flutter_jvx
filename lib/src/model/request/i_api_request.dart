enum Method { GET, PUT, HEAD, POST, PATCH, DELETE }

/// Base class for all outgoing api requests
abstract class IApiRequest {
  Method get httpMethod => Method.POST;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Converts request to json
  Map<String, dynamic> toJson() => {};
}
