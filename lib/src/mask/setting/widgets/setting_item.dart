import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingItem extends StatelessWidget {
  const SettingItem({
    Key? key,
    required this.frontIcon,
    required this.endIcon,
    required this.value,
    required this.title,
    required this.onPressed
  }) : super(key: key);

  /// Icon displayed at the front
  final FaIcon frontIcon;
  /// Icon displayed at the end
  final FaIcon endIcon;
  /// Title of the setting
  final String title;
  /// Value to be displayed
  final String value;
  /// Will be called when item was pressed
  final VoidCallback onPressed;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ListTile(
        leading: frontIcon,
        trailing: endIcon,
        title: Text(title),
        subtitle: Text(value),
        onTap: onPressed,
      ),
    );

  }
}
