import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../commands.dart';
import '../../../../../flutter_jvx.dart';
import '../../../../../services.dart';
import '../../../../../util/jvx_colors.dart';
import '../../../../../util/progress/progress_button.dart';

class LostPasswordCard extends StatefulWidget {
  const LostPasswordCard({super.key});

  @override
  State<LostPasswordCard> createState() => _LostPasswordCardState();
}

class _LostPasswordCardState extends State<LostPasswordCard> {
  final TextEditingController identifierController = TextEditingController();
  ButtonState progressButtonState = ButtonState.idle;

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
                          FlutterJVx.translate("Reset password"),
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
                        child: Text(FlutterJVx.translate("Please enter your e-mail address.")),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            controller: identifierController,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.emailAddress,
                            onSubmitted: (_) => _onResetPasswordPressed(),
                            onTap: resetButton,
                            onChanged: (_) => resetButton(),
                            decoration: InputDecoration(
                              icon: const FaIcon(FontAwesomeIcons.envelope),
                              labelText: "${FlutterJVx.translate("E-Mail")}/${FlutterJVx.translate("Username")}",
                              border: InputBorder.none,
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
                              FlutterJVx.translate("Reset Password").toUpperCase(),
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
                              onPressed: () => _onResetPasswordPressed(),
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
                      child: Text(FlutterJVx.translate("Back")),
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

  void _onResetPasswordPressed() {
    FocusManager.instance.primaryFocus?.unfocus();

    LoginPage.doResetPassword(
      identifier: identifierController.text,
    ).catchError(IUiService().handleAsyncError);
  }
}
