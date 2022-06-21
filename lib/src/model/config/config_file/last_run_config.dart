/// Represents the last config that was used with the app
class LastRunConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Last version of app that was used
  String? version;

  /// Last language of app that was used
  String? language;

  /// Auth code for auto login, if remember me was checked
  String? authCode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LastRunConfig({
    this.language,
    this.version,
    this.authCode,
  });

  LastRunConfig.fromJson({required Map<String, dynamic> pJson})
      : version = pJson["version"],
        language = pJson["language"],
        authCode = pJson["authCode"];

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Used for writing to file
  Map<String, dynamic> toJson() => {
        "version": version,
        "language": language,
        "authCode": authCode,
      };
}
