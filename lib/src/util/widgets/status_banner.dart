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

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum StatusBannerLocation {
  top,
  bottom,
}

class StatusBanner extends StatefulWidget {
  final Widget child;
  final VoidCallback onClose;

  /// The callback to be called when the banner is tapped.
  ///
  /// If null, closes the banner on tap.
  final VoidCallback? onTap;
  final StatusBannerLocation location;
  final Color? backgroundColor;
  final Color? color;
  final double opacity;
  final double elevation;
  final BorderRadius borderRadius;
  final double edgePadding;
  final EdgeInsetsGeometry contentPadding;
  final double dismissThreshold;
  final Curve translationCurve;
  final Duration translationDuration;

  const StatusBanner({
    super.key,
    required this.child,
    required this.onClose,
    this.onTap,
    this.location = StatusBannerLocation.top,
    this.backgroundColor,
    this.color,
    this.opacity = 0.8,
    this.elevation = 6.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.edgePadding = 10,
    this.contentPadding = const EdgeInsets.all(10),
    this.dismissThreshold = 0.7,
    this.translationCurve = Curves.fastOutSlowIn,
    this.translationDuration = const Duration(milliseconds: 250),
  });

  @override
  State<StatusBanner> createState() => StatusBannerState();
}

class StatusBannerState extends State<StatusBanner> with SingleTickerProviderStateMixin {
  final GlobalKey _childKey = GlobalKey(debugLabel: "StatusBanner child");
  late final AnimationController _controller;
  late Tween<double> _tween;
  late ParametricCurve _curve = widget.translationCurve;

  @override
  void initState() {
    super.initState();
    _updateTween();
    _controller = AnimationController(duration: widget.translationDuration, vsync: this);
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onClose.call();
      }
    });
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant StatusBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      _updateTween();
    }
    if (widget.translationCurve != oldWidget.translationCurve) {
      if (_curve == oldWidget.translationCurve) {
        _curve = widget.translationCurve;
      }
    }
    if (widget.translationDuration != oldWidget.translationDuration) {
      _controller.duration = widget.translationDuration;
    }
  }

  void _updateTween() {
    switch (widget.location) {
      case StatusBannerLocation.top:
        _tween = Tween(begin: -1, end: 0);
        break;
      case StatusBannerLocation.bottom:
        _tween = Tween(begin: 1, end: 0);
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> close() async {
    if (!mounted) return;
    // assert(_controller.status != AnimationStatus.dismissed);
    return _controller.reverse();
  }

  double get _childHeight {
    final RenderBox renderBox = _childKey.currentContext!.findRenderObject()! as RenderBox;
    return renderBox.size.height;
  }

  Alignment get _locationAlignment {
    switch (widget.location) {
      case StatusBannerLocation.top:
        return Alignment.topCenter;
      case StatusBannerLocation.bottom:
        return Alignment.bottomCenter;
    }
  }

  EdgeInsetsGeometry get _locationPadding {
    switch (widget.location) {
      case StatusBannerLocation.top:
        return EdgeInsets.only(top: widget.edgePadding);
      case StatusBannerLocation.bottom:
        return EdgeInsets.only(bottom: widget.edgePadding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _locationAlignment,
      child: FractionalTranslation(
        key: _childKey,
        translation: Offset(
          0,
          _tween.transform(_curve.transform(_controller.value)),
        ),
        child: SafeArea(
          child: Padding(
            padding: _locationPadding,
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                // Allow the banner to animate smoothly from its current position without jumps.
                _curve = _SuspendedCurve(_controller.value, curve: widget.translationCurve);
                if (_controller.value < widget.dismissThreshold) {
                  close();
                } else {
                  if (_controller.status != AnimationStatus.reverse) {
                    _controller.forward();
                  } else {
                    // We already tried to close it.
                    _controller.reverse();
                  }
                }
              },
              onVerticalDragUpdate: (details) {
                double adjustedDelta;
                switch (widget.location) {
                  case StatusBannerLocation.top:
                    adjustedDelta = details.delta.dy;
                    break;
                  case StatusBannerLocation.bottom:
                    adjustedDelta = -details.delta.dy;
                    break;
                  default:
                    throw UnimplementedError("Invalid location: ${widget.location}");
                }
                _controller.value = (_controller.value + (adjustedDelta / _childHeight)).clamp(0, 1);
              },
              onVerticalDragStart: (details) {
                // Allow the banner to track the user's finger accurately.
                _curve = Curves.linear;
              },
              child: Opacity(
                opacity: widget.opacity,
                child: Material(
                  elevation: widget.elevation,
                  color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
                  borderRadius: widget.borderRadius,
                  child: InkWell(
                    onTap: widget.onTap ?? () => close(),
                    borderRadius: widget.borderRadius,
                    child: Padding(
                      padding: widget.contentPadding,
                      child: DefaultTextStyle(
                        style: TextStyle(color: widget.color ?? Theme.of(context).colorScheme.onSurface),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// TODO: Use the public version from https://github.com/flutter/flutter/issues/51627 when available
// Copied from scaffold.dart/bottom_sheet.dart as it is private
/// A curve that progresses linearly until a specified [startingPoint], at which
/// point [curve] will begin. Unlike [Interval], [curve] will not start at zero,
/// but will use [startingPoint] as the Y position.
///
/// For example, if [startingPoint] is set to `0.5`, and [curve] is set to
/// [Curves.easeOut], then the bottom-left quarter of the curve will be a
/// straight line, and the top-right quarter will contain the entire contents of
/// [Curves.easeOut].
///
/// This is useful in situations where a widget must track the user's finger
/// (which requires a linear animation), and afterwards can be flung using a
/// curve specified with the [curve] argument, after the finger is released. In
/// such a case, the value of [startingPoint] would be the progress of the
/// animation at the time when the finger was released.
///
/// The [startingPoint] and [curve] arguments must not be null.
class _SuspendedCurve extends ParametricCurve<double> {
  /// Creates a suspended curve.
  const _SuspendedCurve(
    this.startingPoint, {
    required this.curve,
  });

  /// The progress value at which [curve] should begin.
  final double startingPoint;

  /// The curve to use when [startingPoint] is reached.
  final Curve curve;

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    assert(startingPoint >= 0.0 && startingPoint <= 1.0);

    if (t < startingPoint) {
      return t;
    }

    if (t == 1.0) {
      return t;
    }

    final double curveProgress = (t - startingPoint) / (1 - startingPoint);
    final double transformed = curve.transform(curveProgress);
    return lerpDouble(startingPoint, 1, transformed)!;
  }

  @override
  String toString() {
    return '${describeIdentity(this)}($startingPoint, $curve)';
  }
}
