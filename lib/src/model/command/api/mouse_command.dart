import '../../request/api_mouse_request.dart';
import 'api_command.dart';

abstract class MouseCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Component name of the button clicked
  final String componentName;

  /// Which button has been pressed
  final MouseButtonClicked? button;

  /// The x coordinate where the mouse was.
  final double? x;

  /// The y coordinate where the mouse was.
  final double? y;

  /// The amount of times the mouse was clicked
  final int? clickCount;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MouseCommand({
    required super.reason,
    required this.componentName,
    this.button,
    this.clickCount,
    this.x,
    this.y,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "MouseCommand{componentName: $componentName, button: $button, x: $x, y: $y, clickCount: $clickCount, ${super.toString()}}";
  }
}
