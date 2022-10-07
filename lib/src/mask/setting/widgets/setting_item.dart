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
  final Function(T? value)? onPressed;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const SettingItem({
    Key? key,
    required this.title,
    this.value,
    this.valueNotifier,
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
        leading: frontIcon != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  frontIcon!,
                ],
              )
            : null,
        trailing: endIcon,
        title: Text(title),
        subtitle: valueNotifier != null
            ? ValueListenableBuilder<T>(
                valueListenable: valueNotifier!,
                builder: (context, value, child) {
                  return createSubtitle(context, value)!;
                },
              )
            : createSubtitle(context, value as T),
        onTap: () => onPressed?.call(value ?? valueNotifier?.value),
      ),
    );
  }

  Widget? createSubtitle(BuildContext context, T value) {
    return itemBuilder?.call(context, value, null) ??
        (value is String ? Text(value.toString().isNotEmpty ? value.toString() : "-") : null);
  }
}
