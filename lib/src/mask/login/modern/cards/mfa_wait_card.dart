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
import 'mfa_card.dart';

class MFAWaitCard extends StatefulWidget {
  final int? timeout;
  final bool? timeoutReset;
  final String? confirmationCode;

  const MFAWaitCard({
    super.key,
    this.timeout,
    this.timeoutReset,
    this.confirmationCode,
  });

  @override
  State<MFAWaitCard> createState() => _MFAWaitCardState();
}

class _MFAWaitCardState extends State<MFAWaitCard> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late int timeout;
  String? confirmationCode;

  @override
  void initState() {
    super.initState();
    timeout = widget.timeout!;
    confirmationCode = widget.confirmationCode!;
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: timeout),
    )..addListener(() => setState(() {}));
    controller.forward();
  }

  @override
  void didUpdateWidget(covariant MFAWaitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timeoutReset ?? false) {
      controller.reset();
      controller.forward();
    }
    if (widget.timeout != null) {
      controller.duration = Duration(milliseconds: widget.timeout!);
    }
    if (widget.confirmationCode != null) {
      confirmationCode = widget.confirmationCode;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double? timeLeft = controller.lastElapsedDuration != null
        ? ((timeout - controller.lastElapsedDuration!.inMilliseconds) / 1000)
        : null;
    return MFACard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints.tight(const Size.square(100)),
                      child: CircularProgressIndicator(
                        value: 1.0 - controller.value,
                        backgroundColor: Colors.grey,
                        strokeWidth: 20.0,
                      ),
                    ),
                    Text(
                      "${timeLeft?.toStringAsFixed(0) ?? "-"}s",
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(FlutterUI.translate("Matching code")),
                    Text(
                      confirmationCode ?? "-",
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onCancelPressed() {
    LoginPage.cancelLogin().catchError((error, stackTrace) {
      return IUiService().handleAsyncError(error, stackTrace);
    });
  }
}
