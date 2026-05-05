/*
 * Copyright 2026 SIB Visions GmbH
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
import 'package:webview_flutter/webview_flutter.dart';

import '../../../flutter_ui.dart';
import 'webview_dialog_service.dart';

class WebViewDialogWidget extends StatefulWidget {
  final WebViewController controller;

  final String? title;

  final bool dismissible;

  const WebViewDialogWidget({
    super.key,
    this.title,
    this.dismissible = false,
    required this.controller,
  });

  @override
  State<WebViewDialogWidget> createState() => WebViewDialogState();
}

class WebViewDialogState extends State<WebViewDialogWidget> with SingleTickerProviderStateMixin {
  // Animation Controller
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? title;

    if (widget.title != null) {
      title = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 0,
        children: [
          Icon(Icons.webhook_rounded),
          SizedBox(width: 15),
          Flexible(
            fit: FlexFit.tight,
            child: FittedBox(
              alignment: AlignmentGeometry.topLeft,
              fit: BoxFit.scaleDown,
              child: Text(FlutterUI.translate(widget.title))
            )
          )
        ]
      );
    }

    List<Widget>? actions;
    EdgeInsets? actionsPadding;

    if (widget.dismissible) {
      actions = [
        TextButton(
          onPressed: () => WebViewDialogService.hide(),
          child: Text(FlutterUI.translate("Close")),
        )
      ];

      actionsPadding = EdgeInsets.only(
          bottom: Theme.of(context).dialogTheme.actionsPadding?.vertical ?? 15,
          left: 10,
          right: 10,
          top: 10
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: title,
          contentPadding: EdgeInsets.fromLTRB(5, 15, 5, 0),
          content: Builder(
            builder: (context) {

              return WebViewWidget(
                controller: widget.controller
              );
            },
          ),
          insetPadding: EdgeInsets.all(10),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: actionsPadding,
          actions: actions
          ),
      ),
    );
  }

  /// Smooth hide
  Future<void> reverse() async {
    await _controller.reverse();
  }

}
