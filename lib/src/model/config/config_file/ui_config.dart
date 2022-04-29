class UiConfig{

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final bool showLoginRememberMe;

  final bool loginRememberMeChecked;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const UiConfig({
    this.loginRememberMeChecked = true,
    this.showLoginRememberMe = true,
  });

  UiConfig.fromJson({required Map<String, dynamic> json}) :
    showLoginRememberMe = json["showLoginRememberMe"] ?? true,
    loginRememberMeChecked = json["loginRememberMeChecked"] ?? true;

}