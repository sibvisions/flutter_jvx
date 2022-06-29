import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';

class UrlEditor extends StatelessWidget with ConfigServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// TextController for the editing field
  final TextEditingController controller;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UrlEditor({
    required this.controller,
    Key? key,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: configService.translateText('URL'),
        hintText: configService.translateText('Enter new URL'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
