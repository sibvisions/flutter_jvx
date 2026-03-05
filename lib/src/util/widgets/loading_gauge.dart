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

import 'dart:math';

import '../jvx_colors.dart';

class LoadingGauge extends StatefulWidget {
  static const double strokeWidth = 20.0;

  static const Color colorOk = Colors.green;
  static Color colorWarning = Colors.yellow.shade600;
  static const Color colorError = Colors.red;

  final int? timeout;

  final int? error;
  final int? warning;

  final bool? timeoutReset;

  LoadingGauge({
    super.key,
    this.timeout,
    double? warning,
    double? error,
    this.timeoutReset,
  }) : warning = warning?.round(),
       error = error?.round();

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
    int totalMs = timeout ?? 0;

    //We use controller.value for realtime calculation in builder (for smooth animation)

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120, minHeight: 120),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          double remainingMs = (1.0 - controller.value) * totalMs;
          int displayMs = remainingMs.round();

          String timer = timeout == null
              ? "-"
              : "${Duration(milliseconds: displayMs).inMinutes.toString().padLeft(2, "0")}:"
                "${Duration(milliseconds: displayMs).inSeconds.remainder(60).toString().padLeft(2, "0")}";

          // Color of bar
          Color progressColor = LoadingGauge.colorOk;
          const int fadeDuration = 2000;

          if (widget.error != null && remainingMs <= widget.error!) {
            progressColor = LoadingGauge.colorError;
          } else if (widget.warning != null && remainingMs <= widget.warning! + fadeDuration) {
            // fade to warning

            if (remainingMs > widget.warning!) {
              double t = ((widget.warning! + fadeDuration) - remainingMs) / fadeDuration;
              progressColor = Color.lerp(LoadingGauge.colorOk, LoadingGauge.colorWarning, t.clamp(0.0, 1.0))!;
            } else {
              progressColor = LoadingGauge.colorWarning;
            }
          }

          if (widget.error != null && remainingMs <= widget.error! + fadeDuration && remainingMs > widget.error!) {
            // fade to error

            double t = ((widget.error! + fadeDuration) - remainingMs) / fadeDuration;
            Color base = (widget.warning != null && remainingMs <= widget.warning!)
                ? LoadingGauge.colorWarning
                : LoadingGauge.colorOk;
            progressColor = Color.lerp(base, LoadingGauge.colorError, t.clamp(0.0, 1.0))!;
          }

          // text color and blinking for 2 seconds in case of error area
          double scale = 1.0;
          Color textColor = Theme.of(context).textTheme.labelMedium?.color?.withAlpha(180) ?? (JVxColors.isLightTheme(context) ? Colors.black : JVxColors.DARKER_WHITE);

          if (widget.error != null) {
            //how long is error active
            double timeInError = widget.error! - remainingMs;

            // event 1: blink for 2 seconds immediate after mode switch (yellow -> red) (blink only 2 seconds)
            bool isInitialErrorBlink = timeInError >= 0 && timeInError <= 2250;

            // event 2: 5 seconds before the end till the end
            bool isFinalCountdownBlink = remainingMs <= 6000 && remainingMs >= 0;

            if (isInitialErrorBlink || isFinalCountdownBlink) {
              // blink frequency
              double pulseValue = sin(timeInError * 0.01).abs();

              scale = 1.0 + (pulseValue * 0.15);
              textColor = Color.lerp(textColor, LoadingGauge.colorError, pulseValue)!;
            }
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: RoundedGaugePainter(
                    percent: 1.0 - controller.value,
                    color: progressColor,
                    strokeWidth: LoadingGauge.strokeWidth,
                    backgroundColor: JVxColors.isLightTheme(context) ? Colors.grey.shade300 : Colors.grey.shade800
                  ),
                ),
              ),
              Transform.scale(
                scale: scale,
                child: Text(
                  timer,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}

class RoundedGaugePainter extends CustomPainter {
  final double percent;
  final Color color;
  final double strokeWidth;
  final Color backgroundColor;
  final double cornerRadius;

  RoundedGaugePainter({
    required this.percent,
    required this.color,
    required this.strokeWidth,
    required this.backgroundColor,
    this.cornerRadius = 5.0
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = (min(size.width, size.height) / 2);
    final innerR = outerR - strokeWidth;

    // background
    canvas.drawCircle(center, outerR - strokeWidth / 2, Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth);

    if (percent <= 0) return;

    final double startAngle = -pi / 2;
    final double sweepAngle = 2 * pi * percent;
    final double endAngle = startAngle + sweepAngle;

    //we calc the effective radius, because it should shrink if bar gets too short (at the end of time)
    double effectiveRadius = cornerRadius;
    double maxAlpha = sweepAngle / 2.1;
    double outerAlpha = effectiveRadius / outerR;

    if (outerAlpha > maxAlpha) {
      outerAlpha = maxAlpha;
      effectiveRadius = outerAlpha * outerR;
    }

    final double innerAlpha = effectiveRadius / innerR;
    final Radius radius = Radius.circular(effectiveRadius);

    final Path path = Path();

    // Start cap

    // from outside near the corner
    path.moveTo(
      center.dx + outerR * cos(startAngle + outerAlpha),
      center.dy + outerR * sin(startAngle + outerAlpha)
    );

    //  outer corner
    path.arcToPoint(
      Offset(center.dx + (outerR - effectiveRadius) * cos(startAngle),
        center.dy + (outerR - effectiveRadius) * sin(startAngle)
      ),
      radius: radius,
      clockwise: false,
    );

    // flat
    path.lineTo(
      center.dx + (innerR + effectiveRadius) * cos(startAngle),
      center.dy + (innerR + effectiveRadius) * sin(startAngle)
    );

    // inner corner
    path.arcToPoint(
      Offset(center.dx + innerR * cos(startAngle + innerAlpha),
        center.dy + innerR * sin(startAngle + innerAlpha)
      ),
      radius: radius,
      clockwise: false,
    );

    // inside
    path.arcTo(Rect.fromCircle(
      center: center,
      radius: innerR),
      startAngle + innerAlpha,
      max(0.0, sweepAngle - (innerAlpha + (effectiveRadius/innerR))),
      false
    );

    // end cap

    // inner corner
    path.arcToPoint(
      Offset(
        center.dx + (innerR + effectiveRadius) * cos(endAngle),
        center.dy + (innerR + effectiveRadius) * sin(endAngle)
      ),
      radius: radius,
      clockwise: false,
    );

    // flat
    path.lineTo(
      center.dx + (outerR - effectiveRadius) * cos(endAngle),
      center.dy + (outerR - effectiveRadius) * sin(endAngle)
    );

    // outer corner
    path.arcToPoint(
      Offset(
        center.dx + outerR * cos(endAngle - outerAlpha),
        center.dy + outerR * sin(endAngle - outerAlpha)
      ),
      radius: radius,
      clockwise: false,
    );

    // and back
    path.arcTo(Rect.fromCircle(
        center: center,
        radius: outerR
      ),
      endAngle - outerAlpha,
      -max(0.0, (sweepAngle - (outerAlpha + (effectiveRadius/outerR)))),
      false
    );

    path.close();

    canvas.drawPath(path, Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true);
  }

  @override
  bool shouldRepaint(covariant RoundedGaugePainter oldDelegate) =>
      oldDelegate.percent != percent || oldDelegate.color != color;

}