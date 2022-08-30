class UiConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final bool? showRememberMe;
  final bool? rememberMeChecked;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const UiConfig({
    this.showRememberMe,
    this.rememberMeChecked,
  });

  const UiConfig.empty({
    this.showRememberMe = false,
    this.rememberMeChecked = false,
  });

  UiConfig.fromJson({required Map<String, dynamic> json})
      : this(
          showRememberMe: json["showRememberMe"],
          rememberMeChecked: json["rememberMeChecked"],
        );

  UiConfig merge(UiConfig? other) {
    if (other == null) return this;

    return UiConfig(
      showRememberMe: other.showRememberMe ?? showRememberMe,
      rememberMeChecked: other.rememberMeChecked ?? rememberMeChecked,
    );
  }
}
