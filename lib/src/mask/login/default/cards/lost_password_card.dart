import 'package:flutter/material.dart';

import '../../../../../flutter_jvx.dart';
import '../../../../../services.dart';
import '../../../../model/command/api/login_command.dart';

/// Card to be displayed in app-login for resetting the password
class LostPasswordCard extends StatelessWidget {
  /// Controller for Email/Username text field
  final TextEditingController identifierController = TextEditingController();

  LostPasswordCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          FlutterJVx.translate("Reset password"),
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        Text(
          FlutterJVx.translate("Please enter your e-mail address."),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          textInputAction: TextInputAction.done,
          controller: identifierController,
          onSubmitted: (_) => _onResetPasswordPressed(),
          decoration: InputDecoration(
            labelText: FlutterJVx.translate("E-Mail:"),
            hintText: FlutterJVx.translate("E-Mail:"),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        _createBottomRow(),
      ],
    );
  }

  Widget _createBottomRow() {
    Widget okButton = ElevatedButton(
      onPressed: _onResetPasswordPressed,
      child: Text(FlutterJVx.translate("OK")),
    );

    Widget backButton = TextButton(
      onPressed: () => IUiService().routeToLogin(mode: LoginMode.Manual),
      child: Text(
        FlutterJVx.translate("Cancel"),
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: backButton),
        Flexible(child: okButton),
      ],
    );
  }

  void _onResetPasswordPressed() {
    FocusManager.instance.primaryFocus?.unfocus();

    LoginPage.doResetPassword(
      identifier: identifierController.text,
    ).catchError(IUiService().handleAsyncError);
  }
}
