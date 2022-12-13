/* Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/widgets.dart';

import '../../model/command/api/login_command.dart';

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
