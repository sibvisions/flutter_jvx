/*
 * Copyright 2022 SIB Visions GmbH
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

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DebugDetector extends StatefulWidget {
  final Widget child;
  final void Function() callback;
  final Duration delay;
  final double maxSquaredMoveDistance;
  final int pointers;

  const DebugDetector({
    super.key,
    required this.child,
    required this.callback,
    this.delay = const Duration(milliseconds: 750),
    this.maxSquaredMoveDistance = 2,
    this.pointers = 2,
  });

  @override
  State<DebugDetector> createState() => _DebugDetectorState();
}

class _DebugDetectorState extends State<DebugDetector> {
  int pointers = 0;

  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        pointers++;
        if (pointers == widget.pointers) {
          timer?.cancel();
          timer = Timer(widget.delay, () {
            if (pointers == widget.pointers) {
              HapticFeedback.vibrate();
              widget.callback.call();
            }
          });
        } else {
          timer?.cancel();
        }
      },
      onPointerCancel: (event) {
        pointers--;
        timer?.cancel();
      },
      onPointerUp: (event) {
        pointers--;
        timer?.cancel();
      },
      onPointerMove: (event) {
        if (event.delta.distanceSquared > widget.maxSquaredMoveDistance) {
          timer?.cancel();
        }
      },
      child: widget.child,
    );
  }
}
