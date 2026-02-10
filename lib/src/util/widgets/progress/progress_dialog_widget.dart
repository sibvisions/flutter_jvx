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

import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class ProgressDialogWidget extends StatefulWidget {
  final Config config;

  const ProgressDialogWidget({
    super.key,
    required this.config,
  });

  @override
  State<ProgressDialogWidget> createState() => ProgressDialogState();
}

class ProgressDialogState extends State<ProgressDialogWidget> with SingleTickerProviderStateMixin {
  late Config _config;

  // Animation Controller
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _config = widget.config.withDefaults();
    if (_config.message == null) {
      throw Exception("Message has to be set during initialization");
    }

    // Animation Setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward(); // Startet Einblenden
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Diese Methode rufen wir vom Service auf, um sanft auszublenden
  Future<void> reverse() async {
    await _controller.reverse();
  }

  void update(Config config) {
    _config = _config.merge(config);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double? progress = _config.progress == 0 || _config.maxProgress == 0
        ? null
        : _config.progress! / _config.maxProgress!;

    Color effectiveBackgroundColor = _config.backgroundColor ?? Theme.of(context).colorScheme.surface;
    Color effectiveValueColor = _config.progressValueColor ?? Theme.of(context).colorScheme.primary;
    Color effectiveProgressBgColor = _config.progressBgColor ?? Theme.of(context).colorScheme.surface;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: PopScope(
          canPop: _config.barrierDismissible ?? false,
          child: AlertDialog(
            backgroundColor: effectiveBackgroundColor,
            elevation: _config.elevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(_config.borderRadius!)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20,
                  child: progress == null
                      ? Container(
                    decoration: BoxDecoration(
                      color: effectiveValueColor,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(width: 2.0, color: effectiveValueColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13.0),
                      child: LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(effectiveValueColor),
                        backgroundColor: effectiveProgressBgColor,
                      ),
                    ),
                  )
                      : LiquidLinearProgressIndicator(
                    value: progress,
                    valueColor: AlwaysStoppedAnimation(effectiveValueColor),
                    backgroundColor: progress >= 1 ? effectiveValueColor : effectiveProgressBgColor,
                    borderRadius: 15.0,
                    borderWidth: 2.0,
                    borderColor: effectiveValueColor,
                    direction: Axis.horizontal,
                    center: Text(
                      "${"${((progress) * 100).round()}"}%",
                      style: TextStyle(
                        color: progress > 0.58
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
                Center(
                  child: Text(
                    _config.progress == _config.maxProgress!
                        ? _config.completedMessage ?? _config.message!
                        : _config.message!,
                    textAlign: _config.messageTextAlign,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ).merge(_config.messageTextStyle),
                  ),
                ),
              ],
            ),
            contentPadding: _config.contentPadding!,
            buttonPadding: _config.buttonPadding,
            actions: _config.actions,
            actionsPadding: _config.actionsPadding!,
            actionsAlignment: _config.actionsAlignment,
          ),
        ),
      ),
    );
  }
}

class Config {
  /// The message in the dialog
  final String? message;
  final String? completedMessage;

  /// The value of the progress.
  ///
  /// (Default: 0)
  final int? progress;

  /// The maximum value of the progress.
  ///
  /// (Default: 100)
  final int? maxProgress;

  final Color? backgroundColor;
  final Color? progressValueColor;
  final Color? progressBgColor;
  final TextAlign? messageTextAlign;
  final TextStyle? messageTextStyle;

  final double? elevation;
  final double? borderRadius;

  /// Determines whether the dialog closes when the back button or screen is clicked.
  ///
  /// (Default: `false`)
  final bool? barrierDismissible;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? buttonPadding;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? actionsPadding;
  final MainAxisAlignment? actionsAlignment;

  Config({
    this.message,
    this.completedMessage,
    this.progress,
    this.maxProgress,
    this.backgroundColor,
    this.progressValueColor,
    this.progressBgColor,
    this.messageTextAlign,
    this.messageTextStyle,
    this.elevation,
    this.borderRadius,
    this.barrierDismissible,
    this.contentPadding,
    this.buttonPadding,
    this.actions,
    this.actionsPadding,
    this.actionsAlignment,
  });

  Config withDefaults() {
    return Config(
      progress: 0,
      maxProgress: 100,
      messageTextAlign: TextAlign.center,
      borderRadius: 15.0,
      barrierDismissible: false,
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
      actionsPadding: EdgeInsets.zero,
    ).merge(this);
  }

  Config merge(Config? other) {
    if (other == null) return this;

    return Config(
      message: other.message ?? message,
      completedMessage: other.completedMessage ?? completedMessage,
      progress: other.progress ?? progress,
      maxProgress: other.maxProgress ?? maxProgress,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      progressValueColor: other.progressValueColor ?? progressValueColor,
      progressBgColor: other.progressBgColor ?? progressBgColor,
      messageTextAlign: other.messageTextAlign ?? messageTextAlign,
      messageTextStyle: other.messageTextStyle ?? messageTextStyle,
      elevation: other.elevation ?? elevation,
      borderRadius: other.borderRadius ?? borderRadius,
      barrierDismissible: other.barrierDismissible ?? barrierDismissible,
      contentPadding: other.contentPadding ?? contentPadding,
      buttonPadding: other.buttonPadding ?? buttonPadding,
      actions: other.actions ?? actions,
      actionsPadding: other.actionsPadding ?? actionsPadding,
      actionsAlignment: other.actionsAlignment ?? actionsAlignment,
    );
  }
}
