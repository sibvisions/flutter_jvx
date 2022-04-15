import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingItem extends StatelessWidget {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Icon displayed at the front
  final FaIcon? frontIcon;
  /// Icon displayed at the end
  final FaIcon? endIcon;
  /// Title of the setting
  final String title;
  /// Value to be displayed
  final ValueListenable<String> value;
  /// Will be called when item was pressed
  final VoidCallback? onPressed;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const SettingItem({
    Key? key,
    required this.value,
    required this.title,
    this.frontIcon,
    this.endIcon,
    this.onPressed
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ListTile(
        leading: frontIcon,
        trailing: endIcon,
        title: Text(title),
        subtitle: ValueListenableBuilder(
          valueListenable: value,
          builder: (BuildContext buildContext, String value, Widget? widget) {
            return Text(value);
          },
        ),
        onTap: onPressed,
      ),
    );

  }
}
