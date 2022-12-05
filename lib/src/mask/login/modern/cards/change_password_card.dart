import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../flutter_ui.dart';
import '../../../../model/command/api/login_command.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../../../../util/jvx_colors.dart';
import '../../../../util/progress/progress_button.dart';
import '../../../state/loading_bar.dart';
import '../../login_page.dart';

class ChangePasswordCard extends StatefulWidget {
  final bool useOTP;
  final String? username;
  final String? password;

  const ChangePasswordCard({
    super.key,
    required this.useOTP,
    this.username,
    this.password,
  });

  @override
  State<ChangePasswordCard> createState() => _ChangePasswordCardState();
}

class _ChangePasswordCardState extends State<ChangePasswordCard> {
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController oneTimePasswordController = TextEditingController();

  ButtonState progressButtonState = ButtonState.idle;

  bool _passwordHidden = true;
  bool _newPasswordHidden = true;
  bool _confirmPasswordHidden = true;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController(text: widget.username);
    passwordController = TextEditingController(text: widget.password);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor.withOpacity(0.9),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                hintStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
          textTheme: Theme.of(context).textTheme.copyWith(
                subtitle1: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold),
              ),
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontWeight: FontWeight.bold),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 16.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 10 * 8,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          FlutterUI.translate("Change password"),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(FlutterUI.translate(
                          widget.useOTP
                              ? "Please enter your one-time password and set a new password."
                              : "Please enter and confirm the new password.",
                        )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            enabled: widget.useOTP,
                            controller: usernameController,
                            textInputAction: TextInputAction.next,
                            onTap: resetButton,
                            onChanged: (_) => resetButton(),
                            decoration: InputDecoration(
                              icon: const FaIcon(FontAwesomeIcons.user),
                              labelText: FlutterUI.translate("Username"),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!widget.useOTP)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: TextField(
                              enabled: widget.password == null,
                              controller: passwordController,
                              textInputAction: TextInputAction.next,
                              onTap: resetButton,
                              onChanged: (_) => resetButton(),
                              obscureText: _passwordHidden,
                              decoration: InputDecoration(
                                icon: const FaIcon(FontAwesomeIcons.key),
                                labelText: FlutterUI.translate("Password"),
                                border: InputBorder.none,
                                suffixIcon: ExcludeFocus(
                                  child: IconButton(
                                    icon: Icon(
                                      _passwordHidden ? Icons.visibility : Icons.visibility_off,
                                    ),
                                    onPressed: () => setState(() => _passwordHidden = !_passwordHidden),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (widget.useOTP)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: TextField(
                              controller: oneTimePasswordController,
                              textInputAction: TextInputAction.next,
                              onTap: resetButton,
                              onChanged: (_) => resetButton(),
                              decoration: InputDecoration(
                                icon: const FaIcon(FontAwesomeIcons.userSecret),
                                labelText: FlutterUI.translate("One-time password"),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            controller: newPasswordController,
                            textInputAction: TextInputAction.next,
                            onTap: resetButton,
                            onChanged: (_) => resetButton(),
                            obscureText: _newPasswordHidden,
                            decoration: InputDecoration(
                              icon: const FaIcon(FontAwesomeIcons.key),
                              labelText: FlutterUI.translate("New Password"),
                              border: InputBorder.none,
                              suffixIcon: ExcludeFocus(
                                child: IconButton(
                                  icon: Icon(
                                    _newPasswordHidden ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () => setState(() => _newPasswordHidden = !_newPasswordHidden),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            controller: confirmPasswordController,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onChangePasswordPressed(),
                            onTap: resetButton,
                            onChanged: (_) => resetButton(),
                            obscureText: _confirmPasswordHidden,
                            decoration: InputDecoration(
                              icon: const FaIcon(FontAwesomeIcons.key),
                              labelText: FlutterUI.translate("Confirm Password"),
                              border: InputBorder.none,
                              suffixIcon: ExcludeFocus(
                                child: IconButton(
                                  icon: Icon(
                                    _confirmPasswordHidden ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () => setState(() => _confirmPasswordHidden = !_confirmPasswordHidden),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              FlutterUI.translate("Change Password").toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ProgressButton.icon(
                              elevation: 3,
                              maxWidth: 60,
                              minWidth: 60,
                              height: 60,
                              padding: const EdgeInsets.all(16.0),
                              shape: const CircleBorder(),
                              progressIndicatorSize: const Size.square(24.0),
                              progressIndicator: CircularProgressIndicator.adaptive(
                                backgroundColor: JVxColors.toggleColor(Theme.of(context).colorScheme.onPrimary),
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                              ),
                              stateButtons: {
                                ButtonState.idle: const StateButton(
                                  child: IconedButton(
                                    icon: FaIcon(FontAwesomeIcons.arrowRight),
                                  ),
                                ),
                                ButtonState.fail: StateButton(
                                  color: Colors.red.shade600,
                                  textStyle: const TextStyle(color: Colors.white),
                                  child: const IconedButton(
                                    icon: Icon(Icons.cancel),
                                  ),
                                ),
                              },
                              onPressed: () => _onChangePasswordPressed(),
                              state: LoadingBar.of(context)?.show ?? false ? ButtonState.loading : progressButtonState,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => IUiService().routeToLogin(mode: LoginMode.Manual),
                      child: Text(FlutterUI.translate("Back")),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void resetButton() {
    setState(() => progressButtonState = ButtonState.idle);
  }

  void _onChangePasswordPressed() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (newPasswordController.text == confirmPasswordController.text) {
      if (widget.useOTP) {
        LoginPage.doChangePasswordOTP(
          username: usernameController.text,
          password: oneTimePasswordController.text,
          newPassword: newPasswordController.text,
        ).catchError(IUiService().handleAsyncError);
      } else {
        LoginPage.doChangePassword(
          username: usernameController.text,
          password: passwordController.text,
          newPassword: newPasswordController.text,
        ).catchError(IUiService().handleAsyncError);
      }
    } else {
      IUiService().openDialog(
        pIsDismissible: true,
        pBuilder: (context) => AlertDialog(
          title: Text(FlutterUI.translate("Error")),
          content: Text(FlutterUI.translate("The passwords are different!")),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(FlutterUI.translate("Ok")),
            ),
          ],
        ),
      );
    }
  }
}
