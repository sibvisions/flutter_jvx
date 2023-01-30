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
  int? timeout;
  String? confirmationCode;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
    )..addListener(() => setState(() {}));

    if (widget.timeout != null) {
      timeout = widget.timeout;
      controller.duration = Duration(milliseconds: widget.timeout!);
      controller.forward();
    }
    confirmationCode = widget.confirmationCode;
  }

  @override
  void didUpdateWidget(covariant MFAWaitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timeout != null) {
      timeout = widget.timeout;
      controller.duration = Duration(milliseconds: widget.timeout!);
      if (controller.status != AnimationStatus.forward) {
        controller.forward();
      }
    }
    if (widget.timeoutReset ?? false) {
      controller.reset();
      controller.forward();
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
    double? timeLeft = timeout != null && controller.lastElapsedDuration != null
        ? ((timeout! - controller.lastElapsedDuration!.inMilliseconds) / 1000)
        : null;
    String? timer = timeLeft?.toStringAsFixed(0);
    if (timer != null) timer += "s";

    return MFACard(
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
                timer ?? "-",
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
    );
  }
}
