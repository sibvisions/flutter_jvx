import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../flutter_jvx.dart';

class EditorDialog extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The editor widget to be shown
  final Widget editor;

  /// Icon to be displayed at the top of the dialog
  final FaIcon? titleIcon;

  /// Title of the editor, will be show above the editor
  final String titleText;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const EditorDialog({
    required this.editor,
    required this.titleText,
    this.titleIcon,
    Key? key,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: _title(pContext: context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: editor,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _closeButtons(pContext: context),
            ),
          ],
        ));
  }

  /// Returns the
  Widget _closeButtons({required BuildContext pContext}) {
    TextStyle style = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(pContext, false),
          child: Text(FlutterJVx.translate("Cancel"), style: style),
        ),
        const SizedBox(width: 20),
        TextButton(
          onPressed: () => Navigator.pop(pContext, true),
          child: Text(FlutterJVx.translate("Confirm"), style: style),
        ),
      ],
    );
  }

  /// Returns the title Widget of the editor
  /// containing the [titleIcon] and [titleText]
  Widget _title({required BuildContext pContext}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (titleIcon != null) titleIcon!,
        const Padding(padding: EdgeInsets.all(15)),
        Text(
          titleText,
          style: const TextStyle(
            fontSize: 20,
          ),
        )
      ],
    );
  }
}
