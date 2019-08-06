class Startup {
  String applicationName;
  String authKey;

  Startup({this.applicationName, this.authKey});

  Map<String, dynamic> toJson() => {
    'applicationName': applicationName,
    'authKey': authKey
  };
}