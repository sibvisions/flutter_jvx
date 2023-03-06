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

import '../../../../flutter_ui.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../../login_page.dart';

class MFACard extends StatelessWidget {
  final String subTitle;
  final bool showCancel;
  final VoidCallback? onCancel;
  final Widget child;

  const MFACard({
    super.key,
    this.subTitle = "Waiting for verification.",
    this.showCancel = true,
    this.onCancel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          FlutterUI.translate("Verification"),
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        Text(
          FlutterUI.translate(subTitle),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: (showCancel ? 8.0 : 0.0)),
          child: child,
        ),
        if (showCancel)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: onCancel ?? _onCancelPressed,
              child: Text(FlutterUI.translate("Cancel")),
            ),
          ),
      ],
    );
  }

  void _onCancelPressed() {
    LoginPage.cancelLogin().catchError(IUiService().handleAsyncError);
  }
}
