import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../flutterclient.dart';
import '../../../models/api/requests/change_password_request.dart';

class ChangePasswordDialog extends StatefulWidget {
  final String username;
  final String clientId;
  final bool login;
  final AppState? appState;
  final SharedPreferencesManager? manager;
  final bool? rememberMe;
  final String? password;
  final bool oneTime;

  const ChangePasswordDialog(
      {Key? key,
      required this.username,
      required this.clientId,
      required this.login,
      this.appState,
      this.manager,
      this.password,
      this.rememberMe,
      this.oneTime = false})
      : super(key: key);

  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  late TextEditingController _passwordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _repeatNewPasswordController;
  late TextEditingController _usernameController;

  String _password = '';
  String _newPassword = '';
  String _repeatNewPassword = '';

  ApiError? _error;
  bool obsureText = true;

  @override
  void initState() {
    super.initState();

    _passwordController =
        TextEditingController(text: widget.login ? widget.password : '');
    _password = widget.password ?? '';

    _newPasswordController = TextEditingController();
    _repeatNewPasswordController = TextEditingController();
    _usernameController = TextEditingController(text: widget.username);
  }

  @override
  void dispose() {
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: BlocListener<ApiCubit, ApiState>(
        bloc: sl<ApiCubit>(),
        listener: (context, state) async {
          if (state is ApiError) {
            setState(() {
              _error = state;
            });
          } else if (state is ApiResponse) {
            if (state.hasObject<Failure>()) {
              setState(() {
                _error =
                    ApiError(failures: [state.getObjectByType<Failure>()!]);
              });
            } else {
              setState(() {
                _error = null;
              });
            }

            if (widget.login) {
              if (state.request is LoginRequest &&
                  state.hasObject<MenuResponseObject>()) {
                if (state.hasObject<UserDataResponseObject>()) {
                  UserDataResponseObject userData =
                      state.getObjectByType<UserDataResponseObject>()!;
                  widget.appState?.userData = userData;
                  widget.manager?.userData = userData;
                }

                Navigator.of(context).pushReplacementNamed(Routes.menu,
                    arguments: MenuPageArguments(
                        menuItems: state
                            .getObjectByType<MenuResponseObject>()!
                            .entries,
                        listMenuItemsInDrawer: true,
                        response: state.hasObject<ScreenGenericResponseObject>()
                            ? state
                            : null));
              }
            } else {
              Navigator.of(context).pop();

              if (state.hasObject<Failure>()) {
                setState(() {
                  _error =
                      ApiError(failures: [state.getObjectByType<Failure>()!]);
                });
              }
            }
          }
        },
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AutoSizeText(
                  AppLocalizations.of(context)!.text('Change Password'),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 15,
                ),
                if (_error != null && _error!.failures.isNotEmpty) ...[
                  Text(
                    _error!.failures[0].message ?? 'An error occured',
                    style: TextStyle(
                        color:
                            _error!.failures[0].name == ErrorHandler.messageInfo
                                ? Colors.white
                                : Colors.black),
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
                TextField(
                  enabled: widget.oneTime,
                  controller: _usernameController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.text('Username'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5))),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  enabled: !widget.login,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.text(
                        !widget.oneTime ? 'Password' : 'One Time Password'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                    suffix: InkWell(
                      onTap: () {
                        setState(() {
                          obsureText = !obsureText;
                        });
                      },
                      child: Icon(
                        obsureText ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  onChanged: (String changed) => _password = changed,
                  obscureText: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.text('New Password'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                    suffix: InkWell(
                      onTap: () {
                        setState(() {
                          obsureText = !obsureText;
                        });
                      },
                      child: Icon(
                        obsureText ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  onChanged: (String changed) => _newPassword = changed,
                  obscureText: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _repeatNewPasswordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!
                        .text('Repeat New Password'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                    suffix: InkWell(
                      onTap: () {
                        setState(() {
                          obsureText = !obsureText;
                        });
                      },
                      child: Icon(
                        obsureText ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  onChanged: (String changed) => _repeatNewPassword = changed,
                  obscureText: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child:
                            Text(AppLocalizations.of(context)!.text('Close'))),
                    TextButton(
                        onPressed: () async {
                          if (_password.isNotEmpty &&
                              _newPassword.isNotEmpty &&
                              _repeatNewPassword == _newPassword) {
                            if (widget.login || widget.oneTime) {
                              await sl<ApiCubit>().login(LoginRequest(
                                  clientId: widget.clientId,
                                  username: _usernameController.text,
                                  password: _password,
                                  createAuthKey: widget.rememberMe ?? false,
                                  newPassword: _newPassword,
                                  mode: widget.oneTime
                                      ? 'changeOneTimePassword'
                                      : 'changePassword'));
                            } else {
                              await sl<ApiCubit>().changePassword(
                                  ChangePasswordRequest(
                                      clientId: widget.clientId,
                                      password: _password,
                                      newPassword: _newPassword,
                                      username: _usernameController.text));
                            }
                          }
                        },
                        child: Text(AppLocalizations.of(context)!
                            .text('Change Password'))),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
