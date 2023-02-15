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

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingItem<T> extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Icon displayed at the front
  final FaIcon? frontIcon;

  /// Icon displayed at the end
  final FaIcon? endIcon;

  /// Title of the setting
  final String title;

  /// If this widget is enabled
  final bool? enabled;

  /// Value to be displayed
  final T? value;

  /// Value to be displayed
  final ValueNotifier<T>? valueNotifier;

  /// Provide a custom builder for the inner item
  final ValueWidgetBuilder<T>? itemBuilder;

  /// Will be called when item was pressed
  final Function(BuildContext context, T value)? onPressed;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const SettingItem({
    super.key,
    required this.title,
    this.value,
    this.valueNotifier,
    this.enabled,
    this.frontIcon,
    this.endIcon,
    this.onPressed,
    this.itemBuilder,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 21, vertical: 5),
      enabled: enabled ?? true,
      leading: frontIcon != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [frontIcon!],
            )
          : null,
      trailing: endIcon != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [endIcon!],
            )
          : null,
      title: Text(title),
      subtitle: valueNotifier != null
          ? ValueListenableBuilder<T>(
              valueListenable: valueNotifier!,
              builder: (context, value, child) {
                return createSubtitle(context, value)!;
              },
            )
          : createSubtitle(context, value as T),
      onTap: () => onPressed?.call(context, (value ?? valueNotifier?.value) as T),
    );
  }

  Widget? createSubtitle(BuildContext context, T value) {
    return itemBuilder?.call(context, value, null) ??
        (value is String ? Text(value.toString().isNotEmpty ? value.toString() : "-") : null);
  }
}
