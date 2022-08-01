class UiConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final bool showRememberMe;
  final bool rememberMeChecked;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const UiConfig({
    this.showRememberMe = false,
    this.rememberMeChecked = false,
  });

  const UiConfig.empty() : this();

  UiConfig.fromJson({required Map<String, dynamic> json})
      : showRememberMe = json["showRememberMe"] ?? false,
        rememberMeChecked = json["rememberMeChecked"] ?? false;
}
