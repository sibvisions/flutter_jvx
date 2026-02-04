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
import 'package:flutter/services.dart';

import '../../../../components/editor/text_field/fl_text_field_widget.dart';
import '../../../../flutter_ui.dart';
import '../../../../model/command/api/change_password_command.dart';
import '../../../../service/command/i_command_service.dart';
import '../../../../service/config/i_config_service.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../../../../util/jvx_colors.dart';
import '../../login_page.dart';
import '../default_login.dart';

class ChangePassword extends StatefulWidget {
  final String? username;
  final String? password;
  final String? errorMessage;

  final bool asDialog;

  const ChangePassword({
    super.key,
    this.username,
    this.password,
    this.errorMessage,
  }) : asDialog = false;

  const ChangePassword.asDialog({
    super.key,
    this.username,
    this.password,
    this.errorMessage,
  }) : asDialog = true;

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController newPasswordController;
  late TextEditingController repeatPasswordController;

  bool _passwordHidden = true;
  bool _newPasswordHidden = true;
  bool _repeatPasswordHidden = true;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController();
    passwordController = TextEditingController();
    newPasswordController = TextEditingController();
    repeatPasswordController = TextEditingController();

    usernameController.text = widget.username ?? "";
    passwordController.text = widget.password ?? "";

    passwordController.addListener(() {setState(() {});});
    newPasswordController.addListener(() {setState(() {});});
    repeatPasswordController.addListener(() {setState(() {});});
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    newPasswordController.dispose();
    repeatPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPasswordMatch = _isPasswordMatch();
    bool hasNewPassword = newPasswordController.text.isNotEmpty;

    Widget body = Column(
      children: [
        if (!widget.asDialog)
          Text(
            FlutterUI.translate("Change password"),
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        if (!widget.asDialog) const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        Text(FlutterUI.translate("Please enter and confirm the new password.")),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        if (widget.errorMessage != null) DefaultLogin.buildErrorMessage(context, widget.errorMessage!),
        if (widget.errorMessage != null) const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          enabled: false,
          controller: usernameController,
          autocorrect: false,
          spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
          decoration: InputDecoration(
            labelText: FlutterUI.translate("Username:"),
            hintText: FlutterUI.translate("Username"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          enabled: widget.password == null,
          obscureText: _passwordHidden,
          controller: passwordController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: FlutterUI.translate("Password"),
            suffixIcon: passwordController.text.isNotEmpty
                ? ExcludeFocus(
                    child: IconButton(
                      tooltip: FlutterUI.translate(_passwordHidden ? "Show password" : "Hide password"),
                      icon: Icon(
                        _passwordHidden ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _passwordHidden = !_passwordHidden),
                      color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
                      iconSize: FlTextFieldWidget.iconSize,
                    ),
                  )
                : null,
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          obscureText: _newPasswordHidden,
          controller: newPasswordController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: FlutterUI.translate("Password (new):").replaceAll(":", ""),
            suffixIcon: newPasswordController.text.isNotEmpty
                ? ExcludeFocus(
                    child: IconButton(
                      tooltip: FlutterUI.translate(_newPasswordHidden ? "Show password" : "Hide password"),
                      icon: Icon(
                        _newPasswordHidden ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _newPasswordHidden = !_newPasswordHidden),
                      color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
                      iconSize: FlTextFieldWidget.iconSize,
                    ),
                  )
                : null,
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          obscureText: _repeatPasswordHidden,
          controller: repeatPasswordController,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitNewPassword(),
          style: hasNewPassword ? TextStyle(color: isPasswordMatch ? Colors.green : Colors.red) : null,
          decoration: InputDecoration(
            labelText: FlutterUI.translate("Password (confirm):").replaceAll(":", ""),
//            labelStyle: TextStyle(color: newPasswordController.text == repeatPasswordController.text ? Colors.green : Colors.red),
            enabledBorder: hasNewPassword ? (Theme.of(context).inputDecorationTheme.enabledBorder?.copyWith(
              borderSide: BorderSide(
                color: isPasswordMatch ? Colors.green : Colors.red,
                width: Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide.width ?? 1.0,
              ),
            ) ?? UnderlineInputBorder(borderSide: BorderSide(
                color: isPasswordMatch ? Colors.green : Colors.red,
                width: Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide.width ?? 1.0,
              )
            )) : null,
            focusedBorder: hasNewPassword ? (Theme.of(context).inputDecorationTheme.focusedBorder?.copyWith(
              borderSide: BorderSide(
                color: isPasswordMatch ? Colors.green : Colors.red,
                width: Theme.of(context).inputDecorationTheme.focusedBorder?.borderSide.width ?? 2.0,
              ),
            ) ?? UnderlineInputBorder(borderSide: BorderSide(
                color: isPasswordMatch ? Colors.green : Colors.red,
                width: Theme.of(context).inputDecorationTheme.border?.borderSide.width ?? 2.0,
              )
            )) : null,
            suffixIcon: repeatPasswordController.text.isNotEmpty
                ? ExcludeFocus(
                    child: IconButton(
                      tooltip: FlutterUI.translate(_repeatPasswordHidden ? "Show password" : "Hide password"),
                      icon: Icon(
                        _repeatPasswordHidden ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _repeatPasswordHidden = !_repeatPasswordHidden),
                      color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
                      iconSize: FlTextFieldWidget.iconSize,
                    ),
                  )
                : null,
          ),
        ),
        if (!widget.asDialog)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _createButtons(context),
            ),
          )
      ],
    );

    if (widget.asDialog) {
      return AlertDialog(
        title: Text(
          FlutterUI.translate("Change password"),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(child: body),
        contentPadding: const EdgeInsets.all(16.0),
        actions: _createButtons(context),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      );
    } else {
      return body;
    }
  }

  Widget passwordError(BuildContext context) {
    return AlertDialog(
      title: Text(FlutterUI.translate("Error")),
      content: Text(FlutterUI.translate("The passwords are different!")),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(FlutterUI.translate("OK")),
        ),
      ],
    );
  }

  List<Widget> _createButtons(BuildContext context) {
    List<Widget> widgetList = [];

    if (IConfigService().userInfo.value != null) {
      widgetList.add(TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(FlutterUI.translate("Cancel")),
      ));
    }

    if (!widget.asDialog) {
      widgetList.add(ElevatedButton(
        onPressed: _hasPasswordInput() ? _submitNewPassword : null,
        child: Text(FlutterUI.translate("OK")),
      ));
    } else {
      widgetList.add(TextButton(
        onPressed: _hasPasswordInput() ? _submitNewPassword : null,
        child: Text(FlutterUI.translate("OK")),
      ));
    }

    return widgetList;
  }

  void _submitNewPassword() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (newPasswordController.text == repeatPasswordController.text) {
      if (IConfigService().userInfo.value == null) {
        LoginPage.doChangePassword(
          username: usernameController.text,
          password: passwordController.text,
          newPassword: newPasswordController.text,
        );
      } else {
        ICommandService()
            .sendCommand(ChangePasswordCommand(
          username: usernameController.text,
          password: passwordController.text,
          newPassword: newPasswordController.text,
          reason: "Change Password Request",
        ))
            .then((success) {
          if (success) {
            Navigator.of(FlutterUI.getCurrentContext()!).pop();
          } else {
            HapticFeedback.heavyImpact();
          }
        });
      }
    } else {
      IUiService().openDialog(pBuilder: (context) => passwordError(context), pIsDismissible: true);
    }
  }

  bool _isPasswordMatch() {
    return newPasswordController.text == repeatPasswordController.text;
  }

  bool _hasPasswordInput() {
    return passwordController.text.isNotEmpty && newPasswordController.text.isNotEmpty && _isPasswordMatch();
  }
}
