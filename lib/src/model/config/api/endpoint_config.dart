class EndpointConfig {
  final String startup;
  final String login;
  final String openScreen;
  final String deviceStatus;
  final String pressButton;
  final String setValue;
  final String setValues;
  final String downloadImages;
  final String closeTab;
  final String openTab;

  EndpointConfig(
      {required this.startup,
      required this.login,
      required this.openScreen,
      required this.deviceStatus,
      required this.pressButton,
      required this.setValue,
      required this.setValues,
      required this.downloadImages,
      required this.closeTab,
      required this.openTab});
}
