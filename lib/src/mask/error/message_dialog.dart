import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/close_frame_command.dart';
import '../../model/command/api/press_button_command.dart';
import '../../model/command/ui/view/message/open_message_dialog_command.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/parse_util.dart';

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
    super.key,
    required this.command,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: command.title?.isNotEmpty == true ? Text(command.title!) : null,
      content: ParseUtil.isHTML(command.message!) ? Html(data: command.message!) : Text(command.message!),
      actions: [
        ..._getButtons(context, command.buttonType),
      ],
    );
  }

  void close() {
    IUiService().sendCommand(
      CloseFrameCommand(frameName: command.componentId, reason: "Message Dialog was dismissed"),
    );
  }

  void _pressButton(BuildContext context, String componentId) {
    IUiService().sendCommand(PressButtonCommand(
      componentName: componentId,
      reason: "Button has been pressed",
    ));
  }

  List<Widget> _getButtons(BuildContext context, int buttonType) {
    List<Widget> buttonList = [];
    switch (buttonType) {
      case MESSAGE_BUTTON_YES_NO_CANCEL:
        buttonList.addAll([
          _getYesButton(context),
          TextButton(
            onPressed: () => _pressButton(context, command.notOkComponentId!),
            child: Text(command.notOkText ?? FlutterUI.translate("No")),
          ),
          _getCancelButton(context),
        ]);
        break;
      case MESSAGE_BUTTON_YES_NO:
        buttonList.addAll([
          _getYesButton(context),
          TextButton(
            onPressed: () => _pressButton(context, command.cancelComponentId!),
            child: Text(command.cancelText ?? FlutterUI.translate("No")),
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
            child: Text(command.okText ?? FlutterUI.translate("Ok")),
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
      child: Text(command.okText ?? FlutterUI.translate("Yes")),
    );
  }

  Widget _getCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => _pressButton(context, command.cancelComponentId!),
      child: Text(command.cancelText ?? FlutterUI.translate("Cancel")),
    );
  }
}
