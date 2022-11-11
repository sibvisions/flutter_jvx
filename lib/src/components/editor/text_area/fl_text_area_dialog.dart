import 'package:flutter/material.dart';

import '../../../../components.dart';
import '../../../../flutter_jvx.dart';

class FlTextAreaDialog extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const Object CANCEL_OBJECT = Object();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final TextEditingController textController;

  final FocusNode focusNode;

  final FlTextAreaModel model;

  /// The callback notifying that the editor value has changed.
  final Function(String) valueChanged;

  /// The callback notifying that the editor value has changed and the editing was completed.
  final Function(String) endEditing;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextAreaDialog({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.model,
    required this.valueChanged,
    required this.endEditing,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlTextAreaDialogState createState() => FlTextAreaDialogState();
}

class FlTextAreaDialogState extends State<FlTextAreaDialog> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    List<Widget> listBottomButtons = [];

    listBottomButtons.add(
      Flexible(
        flex: 1,
        child: Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            child: Text(
              FlutterJVx.translate("Cancel"),
            ),
            onPressed: () {
              Navigator.of(context).pop(FlTextAreaDialog.CANCEL_OBJECT);
            },
          ),
        ),
      ),
    );

    listBottomButtons.add(
      Flexible(
        flex: 1,
        child: Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            child: Text(
              FlutterJVx.translate("OK"),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );

    widget.focusNode.requestFocus();
    return Dialog(
      insetPadding: const EdgeInsets.all(0.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: FlTextAreaWidget(
                model: widget.model,
                textController: widget.textController,
                focusNode: widget.focusNode,
                valueChanged: (value) {
                  widget.valueChanged(value);
                  // Set state to update the textfield widget.
                  setState(() {});
                },
                endEditing: (value) {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Row(
              children: listBottomButtons,
            ),
          ],
        ),
      ),
    );
  }
}
