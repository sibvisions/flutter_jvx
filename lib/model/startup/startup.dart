class Startup {
  String applicationName;
  String authKey;
  String layoutMode;

  Startup({this.applicationName, this.authKey, this.layoutMode});

  Map<String, dynamic> toJson() => {
    'applicationName': applicationName,
    'authKey': authKey,
    'layoutMode': layoutMode,
  };
}