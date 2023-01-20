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

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class DebugDetector extends StatefulWidget {
  final Widget child;
  final void Function() callback;
  final Duration delay;
  final double? acceptSlopTolerance;
  final int pointers;

  const DebugDetector({
    super.key,
    required this.child,
    required this.callback,
    this.delay = kLongPressTimeout,
    this.acceptSlopTolerance,
    this.pointers = 2,
  });

  @override
  State<DebugDetector> createState() => _DebugDetectorState();
}

class _DebugDetectorState extends State<DebugDetector> {
  int _pointerCounter = 0;
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _pointerCounter++;
        if (_pointerCounter == widget.pointers) {
          _timer?.cancel();
          _timer = Timer(widget.delay, () {
            if (_pointerCounter == widget.pointers) {
              widget.callback.call();
            }
          });
        } else {
          _timer?.cancel();
        }
      },
      onPointerCancel: (event) {
        _pointerCounter--;
        _timer?.cancel();
      },
      onPointerUp: (event) {
        _pointerCounter--;
        _timer?.cancel();
      },
      onPointerMove: (event) {
        if (widget.acceptSlopTolerance != null && event.delta.distanceSquared > widget.acceptSlopTolerance!) {
          _timer?.cancel();
        }
      },
      child: widget.child,
    );
  }
}
