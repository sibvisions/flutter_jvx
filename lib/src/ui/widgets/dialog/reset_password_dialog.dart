import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:flutterclient/src/models/api/requests/reset_password_request.dart';
import 'package:flutterclient/src/models/api/response_objects/login_response_object.dart';
import 'package:flutterclient/src/ui/widgets/dialog/change_password_dialog.dart';
import 'package:flutterclient/src/util/translation/app_localizations.dart';

import '../../../../injection_container.dart';
import '../../../services/remote/cubit/api_cubit.dart';

class ResetPasswordDialog extends StatefulWidget {
  final String clientId;
  final String username;
  final ApiCubit cubit;

  const ResetPasswordDialog(
      {required this.clientId,
      required this.username,
      required this.cubit,
      Key? key})
      : super(key: key);

  @override
  _ResetPasswordDialogState createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  late TextEditingController _identifierController;

  ApiError? _error;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: BlocListener<ApiCubit, ApiState>(
        bloc: widget.cubit,
        listener: (context, state) {
          if (state is ApiResponse) {
            if (state.hasObject<Failure>()) {
              setState(() {
                _error =
                    ApiError(failures: [state.getObjectByType<Failure>()!]);
              });
            }

            if (_error != null) {
              setState(() {
                _error = null;
              });
            }
          } else if (state is ApiError) {
            setState(() {
              _error = state;
            });
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(
                AppLocalizations.of(context)!.text('Reset Password'),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: _identifierController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.text('Email'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
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
                      child: Text(AppLocalizations.of(context)!.text('Close'))),
                  TextButton(
                      onPressed: () async {
                        final request = ResetPasswordRequest(
                            clientId: widget.clientId,
                            identifier: _identifierController.text);

                        widget.cubit.resetPassword(request);
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!
                          .text('Reset Password'))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
