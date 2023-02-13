/* 
 * Copyright 2022 SIB Visions GmbH
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'custom_screen.dart';

/// Custom menu item, used for [CustomScreen].
class CustomMenuItem {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Group name under which this item should appear
  final String group;

  /// Label text of the menu item.
  final String label;

  /// Alternative label text.
  final String? alternativeLabel;

  /// Icon to be used when creating a custom menu item
  final WidgetBuilder? imageBuilder;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CustomMenuItem({
    required this.group,
    required this.label,
    this.alternativeLabel,

    /// Font Awesome Icon to be used when creating a custom menu item
    IconData? faIcon,
    WidgetBuilder? imageBuilder,
  }) : imageBuilder = (imageBuilder ?? (faIcon != null ? (_) => FaIcon(faIcon) : null));
}
