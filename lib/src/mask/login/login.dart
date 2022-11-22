import 'package:flutter/widgets.dart';

import '../../model/command/api/login_command.dart';

export 'default/default_login.dart';
export 'login_page.dart';
export 'modern/modern_login.dart';

abstract class Login {
  /// Returns a background widget.
  ///
  /// [loginLogo] is the path to the logo sent by the server
  ///
  /// [topColor] is either the `logo.topColor`, the `logo.background` or the primary theme color.
  ///
  /// [bottomColor] is `logo.bottomColor`
  Widget buildBackground(BuildContext context, String? loginLogo, Color? topColor, Color? bottomColor);

  /// Returns a card widget depending on the [LoginMode].
  ///
  /// Call the super method to get the default card.
  Widget buildCard(BuildContext context, LoginMode mode);
}
