enum ConnectionType { GET, PUT, HEAD, POST, PATCH, DELETE }

/// Base class for all outgoing api requests
abstract class IApiRequest {
  ConnectionType get conType => ConnectionType.POST;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Converts request to json
  Map<String, dynamic> toJson() => {};
}
