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
import 'package:flutter_html/flutter_html.dart';

import '../../../flutter_jvx.dart';
import '../../util/measure_util.dart';
import '../jvx_dialog.dart';

/// This is a standard template for a server side message.
class MessageDialog extends StatefulWidget with JVxDialog {
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
      //avoid padding
      actions = null;
    }

    return AlertDialog(
      title: _command.title?.isNotEmpty == true ? Text(_command.title!) : null,
      contentPadding: actions == null ? const EdgeInsets.all(24) : null,
      scrollable: true,
      content: _buildContent(context),
      actions: actions,
    );
  }

  void close() {
    ICommandService().sendCommand(CloseFrameCommand(frameName: _command.componentId, reason: "Message Dialog was dismissed"));
  }

  void _pressButton(BuildContext context, String componentId) {
    List<BaseCommand> commands = [];

    if (_command.dataProvider != null
        && (componentId == _command.okComponentId || componentId == _command.notOkComponentId)) {
      commands.add(SetValuesCommand(dataProvider: _command.dataProvider!, columnNames: [_command.columnName!], values: [inputController.text],
          reason: "Value of ${_command.id} set to ${inputController.text}"));
    }

    commands.add(PressButtonCommand(componentName: componentId, reason: "Button has been pressed"));

    ICommandService().sendCommands(commands, abortOnFirstError: true);
  }

  Widget _buildContent(BuildContext context) {
    List<Widget> widgets = [];

    if (ParseUtil.isHTML(_command.message)) {

      Html html = Html(data: _command.message,
          shrinkWrap: true,
          style: {"body": Style(margin: Margins(left: Margin(0),
              top: Margin(0),
              bottom: Margin(0),
              right: Margin(0)))});

      TextDirection textDirection = Directionality.of(context);

      Widget w = MediaQuery(data: MediaQuery.of(context),
          child: Directionality(textDirection: textDirection,
              child: Container(child: html)));

      Size size = MeasureUtil.measureWidget(w);

      //will be shown in full width, because of Padding
      widgets.add(Padding(padding: const EdgeInsets.all(0), child: SizedBox(width: size.width, height: size.height, child: html)));
    }
    else{
      widgets.add(_command.message != null ? Text(_command.message!) : const Text(""));
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

  List<Widget> _getButtons(BuildContext context, int buttonType) {
    List<Widget> buttonList = [];
    switch (buttonType) {
      case MessageDialog.MESSAGE_BUTTON_YES_NO_CANCEL:
        buttonList.addAll([
          _getYesButton(context),
          TextButton(
            onPressed: () => _pressButton(context, _command.notOkComponentId!),
            child: Text(_command.notOkText ?? FlutterUI.translate("No")),
          ),
          _getCancelButton(context),
        ]);
        break;
      case MessageDialog.MESSAGE_BUTTON_YES_NO:
        buttonList.addAll([
          _getYesButton(context),
          TextButton(
            onPressed: () => _pressButton(context, _command.cancelComponentId!),
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
            onPressed: () => _pressButton(context, _command.okComponentId!),
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
      onPressed: () => _pressButton(context, _command.okComponentId!),
      child: Text(_command.okText ?? FlutterUI.translate("Yes")),
    );
  }

  Widget _getCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => _pressButton(context, _command.cancelComponentId!),
      child: Text(_command.cancelText ?? FlutterUI.translate("Cancel")),
    );
  }
}
