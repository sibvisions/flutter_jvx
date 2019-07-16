class Startup {
  String applicationName;

  Startup({this.applicationName});

  Map<String, dynamic> toJson() => {
    'applicationName': applicationName,
  };
}