/* Copyright 2022 SIB Visions GmbH
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

import '../../flutter_ui.dart';

class ProgressDialogWidget extends StatefulWidget {
  final Config config;

  const ProgressDialogWidget({
    super.key,
    required this.config,
  });

  @override
  State<ProgressDialogWidget> createState() => ProgressDialogState();

  /// Can be used to pop the dialog
  static void close(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Can be used to safely pop the dialog
  static void safeClose(GlobalKey<ProgressDialogState> globalKey) {
    if (globalKey.currentWidget != null && globalKey.currentContext != null) {
      try {
        ProgressDialogWidget.close(globalKey.currentContext!);
      } catch (e, stackTrace) {
        FlutterUI.logUI.e("Error while safely closing progress dialog", e, stackTrace);
      }
    }
  }
}

class ProgressDialogState extends State<ProgressDialogWidget> {
  late Config _config;

  @override
  void initState() {
    super.initState();

    _config = widget.config.withDefaults();
    if (_config.message == null) {
      throw Exception("Message has to be set during initialization");
    }
  }

  /// Pass a new (partly filled) config to update the state.
  void update({required Config config}) {
    _config = _config.merge(config);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double? progress =
        _config.progress == 0 || _config.maxProgress == 0 ? null : _config.progress! / _config.maxProgress!;
    Color effectiveValueColor = _config.progressValueColor ?? Theme.of(context).colorScheme.primary;

    return WillPopScope(
      child: AlertDialog(
        backgroundColor: _config.backgroundColor,
        elevation: _config.elevation ?? Theme.of(context).dialogTheme.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(_config.borderRadius!),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              child: progress == null
                  ? Container(
                      decoration: BoxDecoration(
                        color: effectiveValueColor,
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          width: 2.0,
                          color: effectiveValueColor,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13.0),
                        child: LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(effectiveValueColor),
                          backgroundColor: _config.progressBgColor,
                        ),
                      ),
                    )
                  : LiquidLinearProgressIndicator(
                      value: progress,
                      valueColor: AlwaysStoppedAnimation(effectiveValueColor),
                      //Workaround to disable wave on 100%
                      backgroundColor: progress >= 1 ? effectiveValueColor : _config.progressBgColor,
                      borderRadius: 15.0,
                      borderWidth: 2.0,
                      borderColor: effectiveValueColor,
                      direction: Axis.horizontal,
                      center: Text(
                        "${"${((progress) * 100).round()}"}%",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16.0,
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
                  fontSize: 17.0,
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
      onWillPop: () => Future.value(_config.barrierDismissible),
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
      backgroundColor: Colors.white,
      progressBgColor: Colors.white,
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
