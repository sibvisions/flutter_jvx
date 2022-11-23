import 'mouse_command.dart';

class MouseReleasedCommand extends MouseCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MouseReleasedCommand({
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
    return "MouseReleasedCommand{componentName: $componentName, button: $button, x: $x, y: $y, clickCount: $clickCount, ${super.toString()}}";
  }
}
