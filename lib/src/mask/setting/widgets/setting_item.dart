import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../util/constants/i_color.dart';

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
  final Widget Function<T>(BuildContext context, T value, TextStyle textStyle)? itemBuilder;

  /// Will be called when item was pressed
  final Function(T value)? onPressed;

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
    bool backgroundColorIsLight =
        ThemeData.estimateBrightnessForColor(Theme.of(context).backgroundColor) == Brightness.light;

    TextStyle textStyle = TextStyle(
      inherit: true,
      color: backgroundColorIsLight ? IColorConstants.JVX_LIGHTER_BLACK : Colors.white,
      //color: Theme.of(context).colorScheme.onBackground,
    );

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
        title: Text(title, style: textStyle),
        subtitle: valueNotifier != null
            ? ValueListenableBuilder<T>(
                valueListenable: valueNotifier!,
                builder: (context, value, child) {
                  return createSubtitle(context, value, textStyle);
                },
              )
            : createSubtitle(context, value as T, textStyle),
        onTap: () => onPressed?.call(value ?? valueNotifier!.value),
      ),
    );
  }

  Widget createSubtitle(BuildContext context, T value, TextStyle textStyle) {
    return itemBuilder?.call(context, value, textStyle) ??
        Text(
          value.toString().isNotEmpty ? value.toString() : "-",
          style: textStyle,
        );
  }
}
