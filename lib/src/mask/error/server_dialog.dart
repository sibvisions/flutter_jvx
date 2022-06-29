import 'package:flutter/material.dart';
import 'package:flutter_client/main.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';

/// This is a standard template for a server side message.
class ServerDialog extends StatelessWidget with ConfigServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This message will be displayed in the popup
  final String message;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ServerDialog({
    required this.message,
    Key? key,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: themeData.cardColor.withAlpha(255),
      title: Text(configService.translateText("MESSAGE")),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            configService.translateText("OK"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
