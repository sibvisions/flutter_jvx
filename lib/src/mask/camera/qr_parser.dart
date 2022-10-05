import 'dart:convert';

class QRParser {
  static QRAppCode parseCode({required String rawQRCode}) {
    // Static
    const Map<String, String> propertyNameMap = {
      "Applikation": "APPNAME",
      "Application": "APPNAME",
      "PWD": "PWD",
      "USER": "USER",
      "URL": "URL"
    };

    Map<String, String> json = {};

    // If QR-Code is a json it can be easily parsed, otherwise string is split
    // by newLines.
    try {
      json = jsonDecode(rawQRCode);
    } on Exception {
      LineSplitter ls = const LineSplitter();
      List<String> properties = ls.convert(rawQRCode);

      for (String prop in properties) {
        List<String> splitProp = prop.split(": ");
        String propertyName = propertyNameMap[splitProp[0]]!;
        String propertyValue = splitProp[1];
        json[propertyName] = propertyValue;
      }
    }

    return QRAppCode.fromJson(pJson: json);
  }
}

/// All possible info of an APP-QR Code
class QRAppCode {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Url of the remote server
  final String url;

  /// Name of the app
  final String appName;

  /// Username for auto-login
  final String? username;

  /// Password for auto-login
  final String? password;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  QRAppCode({required this.appName, required this.url, this.password, this.username});

  QRAppCode.fromJson({required Map<String, String> pJson})
      : username = pJson['USER'],
        password = pJson['PWD'],
        appName = pJson['APPNAME']!,
        url = pJson['URL']!;
}
