import 'package:flutter/material.dart';

class TextEditor extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String title;
  final String hintText;

  /// TextController for the editing field
  final TextEditingController controller;

  final Function()? onConfirm;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const TextEditor({
    required this.title,
    required this.hintText,
    required this.controller,
    this.onConfirm,
    Key? key,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      controller: controller,
      onEditingComplete: onConfirm,
      decoration: InputDecoration(
        labelText: title,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}
