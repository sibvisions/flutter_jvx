
/// Defines the base construct of a [IConfigService]
/// Config service is used to store & access all configurable data,
/// also stores session based data such as clientId and userData.
// Author: Michael Schober
abstract class IConfigService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns currently set AppName, if appName is not set returns null.
  String? getAppName();

  /// Return currently set clientId, if clientId is not set returns null.
  String? getClientId();

  /// Sets clientId, pass null to unset clientId.
  void setClientId(String? clientId);

  /// Sets appName, pass null to unset appName.
  void setAppName(String? appName);
}