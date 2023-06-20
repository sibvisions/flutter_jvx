/*
 * Copyright 2023 SIB Visions GmbH
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

class ErrorScreen extends StatelessWidget {
  final String message;
  final String? extra;
  final VoidCallback? retry;

  const ErrorScreen({
    super.key,
    this.message = "Error occurred while opening the screen.",
    this.extra,
    this.retry,
  });

  @override
  Widget build(BuildContext context) {
    Widget text = Text(
      FlutterUI.translate(message),
      style: Theme.of(context).textTheme.titleLarge,
    );
    if (extra != null) {
      text = Tooltip(
        message: extra,
        child: text,
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          text,
          if (retry != null) const SizedBox(height: 20),
          if (retry != null)
            ElevatedButton(
              onPressed: retry,
              child: Text(FlutterUI.translate("Retry")),
            )
        ],
      ),
    );
  }
}
