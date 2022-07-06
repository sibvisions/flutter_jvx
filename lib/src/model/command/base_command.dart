import 'package:flutter/cupertino.dart';

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

  /// Callback will be called when all follow-up commands have been fully processed
  final VoidCallback? callback;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  BaseCommand({
    required this.reason,
    this.callback,
  }) : id = DateTime.now().millisecondsSinceEpoch;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return super.toString() + "  reason: $reason";
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns a string to be used for potential logging outputs.
  String get logString;

  /// Returns the delay until the loading progress gets shown.
  Duration get loadingDelay => const Duration(milliseconds: 250);
}
