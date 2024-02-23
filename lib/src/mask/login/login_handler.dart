/*
 * Copyright 2024 SIB Visions GmbH
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

import '../../../flutter_jvx.dart';

typedef ColorBuilder = Color Function(BuildContext context);

/// Used for customization of login
class LoginHandler {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// the login widget builder
  final LoginBuilder? builder;

  /// Builder function for custom login logo
  final WidgetBuilder? logoBuilder;

  /// Builder function for background color
  final ColorBuilder? backgroundColorBuilder;

  /// Builder function for top color
  final ColorBuilder? topColorBuilder;

  /// Builder function for bottom color
  final ColorBuilder? bottomColorBuilder;

  /// whether to use a color gradient instead of linear color
  final bool? colorGradient;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LoginHandler({
    this.builder,
    this.logoBuilder,
    this.backgroundColorBuilder,
    this.topColorBuilder,
    this.bottomColorBuilder,
    this.colorGradient,
  });

}
