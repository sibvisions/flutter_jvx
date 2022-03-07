
/// Defines the base construct of a [IConfigService]
/// Config service is used to store & access all configurable data,
/// also stores session based data such as clientId and userData.
// Author: Michael Schober
abstract class IConfigService {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns current clientId, if none is present returns null
  String? getClientId();

  /// Set clientId
  void setClientId(String? pClientId);

  /// Returns directory of the app, if app is started as web returns null
  String? getDirectory();

  /// Set directory
  void setDirectory(String? pDirectory);

  /// Returns the appName
  String getAppName();

  /// Set appName
  void setAppName(String pAppName);

  /// Returns the url of the remote server
  String getUrl();

  /// Set url
  void setUrl(String pUrl);

  /// Returns version of the server application
  String? getVersion();

  /// Set version
  void setVersion(String pVersion);








}