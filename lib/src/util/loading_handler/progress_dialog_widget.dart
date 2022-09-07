import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class ProgressDialogWidget extends StatefulWidget {
  final Config config;

  const ProgressDialogWidget({
    Key? key,
    required this.config,
  }) : super(key: key);

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
        log("Error while safely closing progress dialog", error: e, stackTrace: stackTrace);
      }
    }
  }
}

class ProgressDialogState extends State<ProgressDialogWidget> {
  late Config _config;

  @override
  void initState() {
    super.initState();

    _config = widget.config;
    _config.fillDefaults();
    if (_config.message == null) {
      throw Exception("Message has to be set during initialization");
    }
  }

  /// Pass a new (partly filled) config to update the state.
  void update({required Config config}) {
    _config.compareAndSet(config);
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
                      value: progress ?? 0.5,
                      valueColor: AlwaysStoppedAnimation(effectiveValueColor),
                      //Workaround to disable wave on 100%
                      backgroundColor:
                          progress != null && progress >= 1 ? effectiveValueColor : _config.progressBgColor,
                      borderRadius: 15.0,
                      borderWidth: 2.0,
                      borderColor: effectiveValueColor,
                      direction: progress != null ? Axis.horizontal : Axis.vertical,
                      center: progress != null
                          ? Text(
                              "${"${((progress) * 100).round()}"}%",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
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
  String? message;
  String? completedMessage;

  /// The value of the progress.
  ///
  /// (Default: 0)
  int? progress;

  /// The maximum value of the progress.
  ///
  /// (Default: 100)
  int? maxProgress;

  Color? backgroundColor;
  Color? progressValueColor;
  Color? progressBgColor;
  TextAlign? messageTextAlign;
  TextStyle? messageTextStyle;

  double? elevation;
  double? borderRadius;

  /// Determines whether the dialog closes when the back button or screen is clicked.
  ///
  /// (Default: [false])
  bool? barrierDismissible;
  EdgeInsetsGeometry? contentPadding;
  EdgeInsetsGeometry? buttonPadding;
  List<Widget>? actions;
  EdgeInsetsGeometry? actionsPadding;
  MainAxisAlignment? actionsAlignment;

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

  void fillDefaults() {
    progress ??= 0;
    maxProgress ??= 100;
    backgroundColor ??= Colors.white;
    progressBgColor ??= Colors.white;
    messageTextAlign ??= TextAlign.center;
    borderRadius ??= 15.0;
    barrierDismissible ??= false;
    contentPadding ??= const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0);
    actionsPadding ??= EdgeInsets.zero;
  }

  void compareAndSet(Config config) {
    if (config.message != null) message = config.message;
    if (config.completedMessage != null) completedMessage = config.completedMessage;
    if (config.progress != null) progress = config.progress;
    if (config.maxProgress != null) maxProgress = config.maxProgress;
    if (config.backgroundColor != null) backgroundColor = config.backgroundColor;
    if (config.progressValueColor != null) progressValueColor = config.progressValueColor;
    if (config.progressBgColor != null) progressBgColor = config.progressBgColor;
    if (config.messageTextAlign != null) messageTextAlign = config.messageTextAlign;
    if (config.messageTextStyle != null) messageTextStyle = config.messageTextStyle;
    if (config.elevation != null) elevation = config.elevation;
    if (config.borderRadius != null) borderRadius = config.borderRadius;
    if (config.barrierDismissible != null) barrierDismissible = config.barrierDismissible;
    if (config.contentPadding != null) contentPadding = config.contentPadding;
    if (config.buttonPadding != null) buttonPadding = config.buttonPadding;
    if (config.actions != null) actions = config.actions;
    if (config.actionsPadding != null) actionsPadding = config.actionsPadding;
    if (config.actionsAlignment != null) actionsAlignment = config.actionsAlignment;
  }
}
