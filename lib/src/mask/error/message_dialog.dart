/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/material.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/close_frame_command.dart';
import '../../model/command/api/press_button_command.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/command/base_command.dart';
import '../../model/command/ui/view/message/open_message_dialog_command.dart';
import '../../service/command/i_command_service.dart';
import '../../util/jvx_colors.dart';
import '../../util/measure_util.dart';
import '../../util/parse_util.dart';
import '../jvx_dialog.dart';

/// This is a standard template for a server side message.
class MessageDialog extends StatefulWidget with JVxDialog {
  /// The type for ok, cancel buttons.
  static const int MESSAGE_BUTTON_OK_CANCEL = 4;

  /// The type for yes, no buttons.
  static const int MESSAGE_BUTTON_YES_NO = 5;

  /// The type for ok button.
  static const int MESSAGE_BUTTON_OK = 6;

  /// The type for yes, no, cancel buttons.
  static const int MESSAGE_BUTTON_YES_NO_CANCEL = 7;

  /// The type for no buttons.
  static const int MESSAGE_BUTTON_NONE = 8;

  /// The type for information icon.
  static const int MESSAGE_ICON_INFO = 0;

  /// The type for warning icon.
  static const int MESSAGE_ICON_WARNING = 1;

  /// The type for error icon.
  static const int MESSAGE_ICON_ERROR = 2;

  /// The type for question icon.
  static const int MESSAGE_ICON_QUESTION = 3;

  /// The type for question icon.
  static const int MESSAGE_ICON_NONE = 9;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// the command
  final OpenMessageDialogCommand command;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MessageDialog({
    required this.command,
  }) : super(key: UniqueKey()) {

    //We need a unique key for all our messages, to use it as stateful widget.
    //without unique key, the same widget will be used for follow-up messages
    //because the componentId is the same

    dismissible = false;
    modal = true;
  }

  @override
  State<MessageDialog> createState() => _MessageDialogState();
}

class _MessageDialogState extends State<MessageDialog> {

  final inputController = TextEditingController();

  /// current command
  late OpenMessageDialogCommand _command;

  late VoidCallback updateListener;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    _command = widget.command.current.value;

    updateListener = () { setState(() {_command = widget.command.current.value; }); };

    widget.command.current.addListener(updateListener);
  }

  @override
  void dispose() {
    super.dispose();

    widget.command.current.removeListener(updateListener);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget>? actions = _getButtons(context, _command.buttonType);

    if (actions.isEmpty) {
      //avoid padding, doesn't work with an empty list!
      actions = null;
    }

    return AlertDialog(
      contentPadding: actions == null ? const EdgeInsets.all(24) : null,
      actionsPadding: actions != null ? JVxColors.ALERTDIALOG_ACTION_PADDING : null,
      title: _command.title?.isNotEmpty == true
        ? Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(_command.title!)
          )
        : null,
      scrollable: true,
      content: _buildContent(context),
      actions: actions,
    );
  }

  void close() {
    ICommandService().sendCommand(CloseFrameCommand(componentName: _command.componentName, reason: "Message Dialog was dismissed"));
  }

  void _pressButton(BuildContext context, String componentName) {
    List<BaseCommand> commands = [];

    if (_command.dataProvider != null
        && (componentName == _command.okComponentName || componentName == _command.notOkComponentName)) {
      commands.add(SetValuesCommand(dataProvider: _command.dataProvider!, columnNames: [_command.columnName!], values: [inputController.text],
          reason: "Value of ${_command.id} set to ${inputController.text}"));
    }

    commands.add(PressButtonCommand(componentName: componentName, reason: "Button has been pressed"));

    ICommandService().sendCommands(commands, abortOnFirstError: true);
  }

  Widget _buildContent(BuildContext context) {
    List<Widget> widgets = [];

    Widget text;

    if (ParseUtil.isHTML(_command.message)) {
      var measure = MeasureUtil.measureHtml(context, _command.message!);

      //will be shown in full width, because of Padding
      text = Padding(padding: const EdgeInsets.all(0), child: SizedBox(width: measure.size.width, height: measure.size.height, child: measure.html));
    }
    else{
      text = _command.message != null ? Text(_command.message!) : const Text("");
    }

    Widget? icon = _getIcon(context, _command.iconType);

    if (icon == null) {
      widgets.add(text);
    }
    else {
      widgets.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: icon
            ),
            Flexible(
              child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [text]
              )
            )
          ]
        )
      ));
    }

    if (_command.dataProvider != null)
    {
      widgets.add(Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextField(
                  controller: inputController,
                  decoration: InputDecoration(labelText: _command.inputLabel),
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: 3,
                )));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  Widget? _getIcon(BuildContext context, int iconType) {
    switch (iconType) {
      case MessageDialog.MESSAGE_ICON_INFO:
        return const Icon(
          Icons.info_outline_rounded,
          size: JVxColors.MESSAGE_ICON_SIZE);
      case MessageDialog.MESSAGE_ICON_WARNING:
        return const Icon(
            Icons.warning_amber_rounded,
            size: JVxColors.MESSAGE_ICON_SIZE);
      case MessageDialog.MESSAGE_ICON_ERROR:
        return const Icon(
            Icons.report_gmailerrorred_rounded,
            size: JVxColors.MESSAGE_ICON_SIZE);
      case MessageDialog.MESSAGE_ICON_QUESTION:
        return const Icon(
            Icons.help_outline_rounded,
            size: JVxColors.MESSAGE_ICON_SIZE);
      case MessageDialog.MESSAGE_ICON_NONE:
      default:
        return null;
    }
  }

  List<Widget> _getButtons(BuildContext context, int buttonType) {
    List<Widget> buttonList = [];
    switch (buttonType) {
      case MessageDialog.MESSAGE_BUTTON_YES_NO_CANCEL:
        buttonList.addAll([
          _getYesButton(context),
          TextButton(
            onPressed: () => _pressButton(context, _command.notOkComponentName!),
            child: Text(_command.notOkText ?? FlutterUI.translate("No")),
          ),
          _getCancelButton(context),
        ]);
        break;
      case MessageDialog.MESSAGE_BUTTON_YES_NO:
        buttonList.addAll([
          _getYesButton(context),
          TextButton(
            onPressed: () => _pressButton(context, _command.cancelComponentName!),
            child: Text(_command.cancelText ?? FlutterUI.translate("No")),
          ),
        ]);
        break;
      case MessageDialog.MESSAGE_BUTTON_OK_CANCEL:
        buttonList.add(_getCancelButton(context));
        continue OK;
      OK:
      case MessageDialog.MESSAGE_BUTTON_OK:
        buttonList.add(
          TextButton(
            onPressed: () => _pressButton(context, _command.okComponentName!),
            child: Text(_command.okText ?? FlutterUI.translate("OK")),
          ),
        );
        break;
      case MessageDialog.MESSAGE_BUTTON_NONE:
      default:
        break;
    }
    return buttonList;
  }

  Widget _getYesButton(BuildContext context) {
    return TextButton(
      onPressed: () => _pressButton(context, _command.okComponentName!),
      child: Text(_command.okText ?? FlutterUI.translate("Yes")),
    );
  }

  Widget _getCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => _pressButton(context, _command.cancelComponentName!),
      child: Text(_command.cancelText ?? FlutterUI.translate("Cancel")),
    );
  }
}
