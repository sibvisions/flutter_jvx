import 'mouse_command.dart';

class MousePressedCommand extends MouseCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MousePressedCommand({
    required super.reason,
    required super.componentName,
    super.button,
    super.clickCount,
    super.x,
    super.y,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "MousePressedCommand{componentName: $componentName, button: $button, x: $x, y: $y, clickCount: $clickCount, ${super.toString()}}";
  }
}
