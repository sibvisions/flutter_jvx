import 'package:flutter/material.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../model/command/api/close_frame_command.dart';
import '../../model/command/api/press_button_command.dart';
import '../../model/command/ui/view/message/open_message_dialog_command.dart';

/// This is a standard template for a server side message.
class MessageDialog extends StatelessWidget {
  /// the type for ok, cancel buttons.
  static const int MESSAGE_BUTTON_OK_CANCEL = 4;

  /// the type for yes, no buttons.
  static const int MESSAGE_BUTTON_YES_NO = 5;

  /// the type for ok button.
  static const int MESSAGE_BUTTON_OK = 6;

  /// the type for yes, no, cancel buttons.
  static const int MESSAGE_BUTTON_YES_NO_CANCEL = 7;

  /// the type for no buttons.
  static const int MESSAGE_BUTTON_NONE = 8;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final OpenMessageDialogCommand command;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const MessageDialog({
    required this.command,
    Key? key,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _closeScreen(context);
        return true;
      },
      child: AlertDialog(
        backgroundColor: Theme.of(context).cardColor.withAlpha(255),
        title: Text(FlutterJVx.translate(command.title)),
        content: Text(FlutterJVx.translate(command.message!)),
        actions: [
          ..._getButtons(context, command.buttonType),
        ],
      ),
    );
  }

  void _closeScreen(BuildContext context) {
    CloseFrameCommand closeScreenCommand =
        CloseFrameCommand(frameName: command.componentId, reason: "Message Dialog was dismissed");
    IUiService().sendCommand(closeScreenCommand);
  }

  void _pressButton(BuildContext context, String componentId) {
    IUiService().sendCommand(PressButtonCommand(
      componentName: componentId,
      reason: "Button has been pressed",
    ));
    Navigator.of(context).pop();
  }

  List<Widget> _getButtons(BuildContext context, int buttonType) {
    List<Widget> buttonList = [];
    switch (buttonType) {
      case MESSAGE_BUTTON_YES_NO_CANCEL:
        buttonList.addAll([
          _getYesButton(context),
          TextButton(
            onPressed: () => _pressButton(context, command.notOkComponentId!),
            child: Text(FlutterJVx.translate("No")),
          ),
          _getCancelButton(context),
        ]);
        break;
      case MESSAGE_BUTTON_YES_NO:
        buttonList.addAll([
          _getYesButton(context),
          TextButton(
            onPressed: () => _pressButton(context, command.cancelComponentId!),
            child: Text(FlutterJVx.translate("No")),
          ),
        ]);
        break;
      case MESSAGE_BUTTON_OK_CANCEL:
        buttonList.add(_getCancelButton(context));
        continue OK;
      OK:
      case MESSAGE_BUTTON_OK:
        buttonList.add(
          TextButton(
            onPressed: () => _pressButton(context, command.okComponentId!),
            child: Text(FlutterJVx.translate("Ok")),
          ),
        );
        break;
      case MESSAGE_BUTTON_NONE:
      default:
        break;
    }
    return buttonList;
  }

  Widget _getYesButton(BuildContext context) {
    return TextButton(
      onPressed: () => _pressButton(context, command.okComponentId!),
      child: Text(FlutterJVx.translate("Yes")),
    );
  }

  Widget _getCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => _pressButton(context, command.cancelComponentId!),
      child: Text(FlutterJVx.translate("Cancel")),
    );
  }
}
