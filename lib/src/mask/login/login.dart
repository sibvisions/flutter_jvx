import 'package:flutter/widgets.dart';

import '../../model/command/api/login_command.dart';

export 'default/default_login.dart';
export 'login_page.dart';
export 'modern/modern_login.dart';

abstract class Login {
  /// Returns the background widget.
  ///
  /// * [loginLogo] is derived from `login.logo` and represents the path to the logo.
  /// * [topColor] is either derived from `logo.topColor`, `logo.background` or the primary theme color.
  /// * [bottomColor] is derived from `logo.bottomColor` and controls the bottom color.
  /// * [colorGradient] is derived from `login.colorGradient` and controls the background gradient.
  Widget buildBackground(
    BuildContext context,
    String? loginLogo,
    Color? topColor,
    Color? bottomColor,
    bool colorGradient,
  );

  /// Returns a card widget depending on the [LoginMode].
  ///
  /// Call the super method to get the default card.
  Widget buildCard(BuildContext context, LoginMode mode);
}
