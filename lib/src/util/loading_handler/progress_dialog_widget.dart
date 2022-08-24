import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../main.dart';
import '../../../util/image/image_loader.dart';

enum ProgressType { normal, valuable }

enum ValueType { none, number, percentage }

enum ValuePosition { center, right }

/// Based on https://github.com/emreesen27/Flutter-Progress-Dialog
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
    return WillPopScope(
      child: AlertDialog(
        backgroundColor: _config.backgroundColor,
        elevation: _config.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(_config.borderRadius!),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: _config.maxProgress! > 0 && _config.progress == _config.maxProgress
                      ? (_config.completed?.image != null
                          ? Image(image: _config.completed!.image!)
                          : SvgPicture.asset(
                              'assets/images/completed_check.svg',
                              theme: SvgTheme(currentColor: _config.progressValueColor!),
                              package: FlutterJVx.package ? ImageLoader.getPackageName() : null,
                            ))
                      : CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color?>(_config.progressValueColor),
                          backgroundColor: _config.progressBgColor,
                          value: (_config.progressType == ProgressType.normal ||
                                  _config.progress == 0 ||
                                  _config.maxProgress == 0
                              ? null
                              : _config.progress! / _config.maxProgress!),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      top: 8.0,
                      bottom: 8.0,
                    ),
                    child: Text(
                      _config.progress == _config.maxProgress!
                          ? _config.completed?.message ?? _config.message!
                          : _config.message!,
                      textAlign: _config.messageTextAlign,
                      maxLines: _config.messageMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: _config.messageFontSize,
                        color: _config.messageColor,
                        fontWeight: _config.messageFontWeight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _config.valueType != ValueType.none &&
                    (_config.progress! > 0 || _config.progressType == ProgressType.valuable)
                ? Align(
                    child: Text(
                      _config.valueType == ValueType.number
                          ? '${_config.progress}/${_config.maxProgress}'
                          : (_config.maxProgress! > 0
                              ? "${(_config.progress! / _config.maxProgress! * 100).round()}%"
                              : "0%"),
                      style: TextStyle(
                        fontSize: _config.valueFontSize,
                        color: _config.valueColor,
                        fontWeight: _config.valueFontWeight,
                      ),
                    ),
                    alignment:
                        _config.valuePosition == ValuePosition.right ? Alignment.bottomRight : Alignment.bottomCenter,
                  )
                : Container()
          ],
        ),
      ),
      onWillPop: () => Future.value(_config.barrierDismissible),
    );
  }
}

class ProgressCompleted {
  /// The message that will be shown when [progress] = [maxProgress]
  final String? message;

  /// The image which should be displayed when the progress is completed, instead of the progress indicator
  final ImageProvider? image;

  ProgressCompleted({
    this.message,
    this.image,
  });
}

class Config {
  /// The message in the dialog
  String? message;

  /// The value of the progress.
  ///
  /// (Default: 0)
  int? progress;

  /// The maximum value of the progress.
  ///
  /// (Default: 100)
  int? maxProgress;
  ProgressCompleted? completed;

  /// The progress bar type.
  ///
  /// (Default: [ProgressType.normal])
  ProgressType? progressType;

  /// Type of the value. (None hides the value)
  ///
  /// (Default: [ValueType.percentage])
  ValueType? valueType;

  /// Location of progress value
  ///
  /// (Default: [ValuePosition.right])
  ValuePosition? valuePosition;
  Color? backgroundColor;
  Color? barrierColor;
  Color? progressValueColor;
  Color? progressBgColor;
  Color? valueColor;
  Color? messageColor;
  TextAlign? messageTextAlign;
  FontWeight? messageFontWeight;
  double? messageFontSize;
  FontWeight? valueFontWeight;
  double? valueFontSize;

  /// Will be used for [Text.maxLines]
  ///
  /// (Default: [1])
  int? messageMaxLines;
  double? elevation;
  double? borderRadius;

  /// Determines whether the dialog closes when the back button or screen is clicked.
  ///
  /// (Default: [false])
  bool? barrierDismissible;

  Config({
    this.message,
    this.progress,
    this.maxProgress,
    this.completed,
    this.progressType,
    this.valueType,
    this.valuePosition,
    this.backgroundColor,
    this.barrierColor,
    this.progressValueColor,
    this.progressBgColor,
    this.valueColor,
    this.messageColor,
    this.messageTextAlign,
    this.messageFontWeight,
    this.messageFontSize,
    this.valueFontWeight,
    this.valueFontSize,
    this.messageMaxLines,
    this.elevation,
    this.borderRadius,
    this.barrierDismissible,
  });

  void fillDefaults() {
    progress ??= 0;
    maxProgress ??= 100;
    progressType ??= ProgressType.normal;
    valueType ??= ValueType.percentage;
    valuePosition ??= ValuePosition.right;
    backgroundColor ??= Colors.white;
    barrierColor ??= Colors.transparent;
    progressValueColor ??= Colors.blueAccent;
    progressBgColor ??= Colors.blueGrey;
    valueColor ??= Colors.black87;
    messageColor ??= Colors.black87;
    messageTextAlign ??= TextAlign.center;
    messageFontWeight ??= FontWeight.bold;
    valueFontWeight ??= FontWeight.normal;
    valueFontSize ??= 15.0;
    messageFontSize ??= 17.0;
    messageMaxLines ??= 1;
    elevation ??= 5.0;
    borderRadius ??= 15.0;
    barrierDismissible ??= false;
  }

  void compareAndSet(Config config) {
    if (config.message != null) message = config.message;
    if (config.progress != null) progress = config.progress;
    if (config.maxProgress != null) maxProgress = config.maxProgress;
    if (config.completed != null) completed = config.completed;
    if (config.progressType != null) progressType = config.progressType;
    if (config.valueType != null) valueType = config.valueType;
    if (config.valuePosition != null) valuePosition = config.valuePosition;
    if (config.backgroundColor != null) backgroundColor = config.backgroundColor;
    if (config.barrierColor != null) barrierColor = config.barrierColor;
    if (config.progressValueColor != null) progressValueColor = config.progressValueColor;
    if (config.progressBgColor != null) progressBgColor = config.progressBgColor;
    if (config.valueColor != null) valueColor = config.valueColor;
    if (config.messageColor != null) messageColor = config.messageColor;
    if (config.messageTextAlign != null) messageTextAlign = config.messageTextAlign;
    if (config.messageFontWeight != null) messageFontWeight = config.messageFontWeight;
    if (config.messageFontSize != null) messageFontSize = config.messageFontSize;
    if (config.messageMaxLines != null) messageMaxLines = config.messageMaxLines;
    if (config.valueFontWeight != null) valueFontWeight = config.valueFontWeight;
    if (config.valueFontSize != null) valueFontSize = config.valueFontSize;
    if (config.elevation != null) elevation = config.elevation;
    if (config.borderRadius != null) borderRadius = config.borderRadius;
    if (config.barrierDismissible != null) barrierDismissible = config.barrierDismissible;
  }
}
