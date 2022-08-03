import 'package:flutter/foundation.dart';
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
  final ValueListenable<T> value;

  /// Provide a custom builder for the inner item
  final ValueWidgetBuilder<T>? itemBuilder;

  /// Will be called when item was pressed
  final VoidCallback? onPressed;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const SettingItem({
    Key? key,
    required this.value,
    required this.title,
    this.enabled,
    this.frontIcon,
    this.endIcon,
    this.onPressed,
    this.itemBuilder,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ListTile(
        enabled: enabled ?? true,
        leading: frontIcon,
        trailing: endIcon,
        title: Text(title),
        subtitle: ValueListenableBuilder<T>(
          valueListenable: value,
          builder: (BuildContext buildContext, T value, Widget? widget) {
            return itemBuilder?.call(buildContext, value, widget) ??
                Text(value.toString().isNotEmpty ? value.toString() : "-");
          },
        ),
        onTap: onPressed,
      ),
    );
  }
}
