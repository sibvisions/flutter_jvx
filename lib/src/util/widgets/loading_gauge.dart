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

class LoadingGauge extends StatefulWidget {
  static const double strokeWidth = 20.0;

  final int? timeout;
  final bool? timeoutReset;

  const LoadingGauge({
    super.key,
    this.timeout,
    this.timeoutReset,
  });

  @override
  State<LoadingGauge> createState() => _LoadingGaugeState();
}

class _LoadingGaugeState extends State<LoadingGauge> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  int? timeout;

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
  }

  @override
  void didUpdateWidget(covariant LoadingGauge oldWidget) {
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
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Duration? timeLeft = timeout != null && controller.lastElapsedDuration != null
        ? Duration(milliseconds: timeout! - controller.lastElapsedDuration!.inMilliseconds)
        : null;
    String? timer;
    if (timeLeft != null) {
      timer = timeLeft.inSeconds.remainder(60).toString().padLeft(2, "0");
      if (timeLeft.inMinutes > 0) {
        timer = "${timeLeft.inMinutes}:$timer";
      }
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120, minHeight: 120),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: LoadingGauge.strokeWidth / 2,
            right: LoadingGauge.strokeWidth / 2,
            top: LoadingGauge.strokeWidth / 2,
            bottom: LoadingGauge.strokeWidth / 2,
            child: CircularProgressIndicator(
              value: 1.0 - controller.value,
              backgroundColor: Colors.grey,
              strokeWidth: LoadingGauge.strokeWidth,
            ),
          ),
          Text(
            timer ?? "-",
            style: const TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
