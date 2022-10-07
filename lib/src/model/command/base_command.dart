import 'package:flutter/widgets.dart';

///
/// Base Class for communication between services, every [BaseCommand] should always be directed at a specific Service.
///
///
abstract class BaseCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Generated ID -> DateTime.now().millisecondsSinceEpoch
  final int id;

  /// Descriptive Reason why this Command was issued.
  final String reason;

  /// If a loading progress should be displayed for this instance.
  final bool showLoading;

  /// Will be called when the command is being processed.
  VoidCallback? beforeProcessing;

  /// Will be called when the command is done processing.
  VoidCallback? afterProcessing;

  /// Internal callback, when all follow-up commands have been fully processed and the command therefore is done processing.
  VoidCallback? onFinish;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  BaseCommand({
    required this.reason,
    this.beforeProcessing,
    this.afterProcessing,
    this.onFinish,
    this.showLoading = true,
  }) : id = DateTime.now().millisecondsSinceEpoch;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "ShowLoading: $showLoading | LoadingDelay: $loadingDelay | Reason: $reason";
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the delay until the loading progress gets shown.
  Duration get loadingDelay => const Duration(milliseconds: 250);
}
