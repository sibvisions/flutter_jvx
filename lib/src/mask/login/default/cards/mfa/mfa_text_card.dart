/*
 * Copyright 2022-2023 SIB Visions GmbH
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

import '../../../../../flutter_ui.dart';
import '../../../../../service/ui/i_ui_service.dart';
import '../../../login_page.dart';
import '../mfa_card.dart';

class MFATextCard extends StatefulWidget {
  final String? username;
  final String? password;

  const MFATextCard({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<MFATextCard> createState() => _MFATextCardState();
}

class _MFATextCardState extends State<MFATextCard> {
  late final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MFACard(
      subTitle: "Please enter your confirmation code.",
      showCancel: false,
      child: Column(
        children: [
          TextField(
            controller: codeController,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.visiblePassword,
            onSubmitted: (_) => _onLoginPressed(),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(bottom: 12.0),
              labelText: FlutterUI.translate("Code"),
              hintText: FlutterUI.translate("Code"),
            ),
          ),
          const SizedBox(height: 20.0),
          _createBottomRow(),
        ],
      ),
    );
  }

  Widget _createBottomRow() {
    Widget okButton = ElevatedButton(
      onPressed: _onLoginPressed,
      child: Text(FlutterUI.translate("OK")),
    );

    Widget backButton = TextButton(
      onPressed: _onCancelPressed,
      child: Text(
        FlutterUI.translate("Cancel"),
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

  void _onCancelPressed() {
    LoginPage.cancelLogin().catchError((error, stackTrace) {
      return IUiService().handleAsyncError(error, stackTrace);
    });
  }

  void _onLoginPressed() {
    FocusManager.instance.primaryFocus?.unfocus();

    LoginPage.doMFALogin(
      username: widget.username,
      confirmationCode: codeController.text,
    ).catchError((error, stackTrace) {
      return IUiService().handleAsyncError(error, stackTrace);
    });
  }
}
