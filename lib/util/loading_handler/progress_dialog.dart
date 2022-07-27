import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

import '../misc/multi_value_listenable_builder.dart';

enum ValuePosition { center, right }

enum ProgressType { normal, valuable }

/// Based on https://github.com/emreesen27/Flutter-Progress-Dialog
class ProgressDialog {
  /// Listens to the value of progress.
  final ValueNotifier<int> _progress = ValueNotifier<int>(0);

  /// Listens to the value of max.
  final ValueNotifier<int> _maxProgress = ValueNotifier<int>(100);

  /// Listens to the msg value.
  final ValueNotifier<String> _msg = ValueNotifier<String>("");

  /// Shows whether the dialog is open.
  bool _dialogIsOpen = false;

  /// Required to show the alert.
  late BuildContext _context;

  ProgressDialog({required context}) {
    _context = context;
  }

  /// Pass the new value to this method to update the status.
  void update({int? value, int? max, String? msg}) {
    if (value != null) _progress.value = value;
    if (max != null) _maxProgress.value = max;
    if (msg != null) _msg.value = msg;
  }

  /// Closes the progress dialog.
  void close() {
    if (_dialogIsOpen) {
      Navigator.pop(_context);
      _dialogIsOpen = false;
    }
  }

  /// Returns whether the dialog box is open.
  bool isOpen() {
    return _dialogIsOpen;
  }

  /// Assigns progress properties and updates the value.
  _valueProgress({Color? valueColor, Color? bgColor, required double value}) {
    return CircularProgressIndicator(
      backgroundColor: bgColor,
      valueColor: AlwaysStoppedAnimation<Color?>(valueColor),
      value: value.toDouble() / 100,
    );
  }

  /// Assigns progress properties.
  _normalProgress({Color? valueColor, Color? bgColor}) {
    return CircularProgressIndicator(
      backgroundColor: bgColor,
      valueColor: AlwaysStoppedAnimation<Color?>(valueColor),
    );
  }

  /// [value] Assign the starting value of the progress.
  // (Default: 0)

  /// [max] Assign the maximum value of the progress.
  // (Default: 100)

  /// [msg] Show a message @required

  /// [valuePosition] Location of progress value
  // Center or right. (Default: right)

  /// [progressType] Assign the progress bar type.
  // Normal or valuable.  (Default: normal)

  /// [barrierDismissible] Determines whether the dialog closes when the back button or screen is clicked.
  // True or False (Default: false)

  /// [msgMaxLines] Use when text value doesn't fit
  // Int (Default: 1)

  /// [hideValue] If you are not using the progress value, you can hide it.
  // Default (Default: false)

  show({
    required String msg,
    int value = 0,
    int max = 100,
    ProgressCompleted? completed,
    ProgressType progressType = ProgressType.normal,
    ValuePosition valuePosition = ValuePosition.right,
    Color backgroundColor = Colors.white,
    Color barrierColor = Colors.transparent,
    Color progressValueColor = Colors.blueAccent,
    Color progressBgColor = Colors.blueGrey,
    Color valueColor = Colors.black87,
    Color msgColor = Colors.black87,
    TextAlign msgTextAlign = TextAlign.center,
    FontWeight msgFontWeight = FontWeight.bold,
    FontWeight valueFontWeight = FontWeight.normal,
    double valueFontSize = 15.0,
    double msgFontSize = 17.0,
    int msgMaxLines = 1,
    double elevation = 5.0,
    double borderRadius = 15.0,
    bool barrierDismissible = false,
    bool hideValue = false,
  }) {
    _progress.value = value;
    _maxProgress.value = max;
    _dialogIsOpen = true;
    _msg.value = msg;
    return showDialog(
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      context: _context,
      builder: (context) => WillPopScope(
        child: AlertDialog(
          backgroundColor: backgroundColor,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(borderRadius),
            ),
          ),
          content: MultiValueListenableBuilder(
            valueListenables: [_progress, _maxProgress],
            builder: (BuildContext context, List<dynamic> values, Widget? child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      values[0] == values[1]
                          ? Image(
                              width: 40,
                              height: 40,
                              image: completed?.image ?? const Svg('assets/images/completed_check.svg'),
                            )
                          : SizedBox(
                              width: 35.0,
                              height: 35.0,
                              child: progressType == ProgressType.normal
                                  ? _normalProgress(
                                      bgColor: progressBgColor,
                                      valueColor: progressValueColor,
                                    )
                                  : values[0] == 0
                                      ? _normalProgress(
                                          bgColor: progressBgColor,
                                          valueColor: progressValueColor,
                                        )
                                      : _valueProgress(
                                          valueColor: progressValueColor,
                                          bgColor: progressBgColor,
                                          value: (values[0] / values[1]) * 100,
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
                            values[0] == values[1] ? completed?.msg ?? _msg.value : _msg.value,
                            textAlign: msgTextAlign,
                            maxLines: msgMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: msgFontSize,
                              color: msgColor,
                              fontWeight: msgFontWeight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  hideValue == false && values[0] > 0
                      ? Align(
                          child: Text(
                            values[0] <= 0 ? '' : '${_progress.value}/${_maxProgress.value}',
                            style: TextStyle(
                              fontSize: valueFontSize,
                              color: valueColor,
                              fontWeight: valueFontWeight,
                            ),
                          ),
                          alignment:
                              valuePosition == ValuePosition.right ? Alignment.bottomRight : Alignment.bottomCenter,
                        )
                      : Container()
                ],
              );
            },
          ),
        ),
        onWillPop: () {
          if (barrierDismissible) {
            _dialogIsOpen = false;
          }
          return Future.value(barrierDismissible);
        },
      ),
    );
  }
}

class ProgressCompleted {
  /// [msg] Assign a completed Message
  final String? msg;

  /// [image] Assign a image which should be displayed when the progress is completed, instead of the progress indicator
  final ImageProvider? image;

  ProgressCompleted({
    this.msg,
    this.image,
  });
}
