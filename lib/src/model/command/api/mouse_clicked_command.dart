import 'mouse_command.dart';

class MouseClickedCommand extends MouseCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MouseClickedCommand({
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
    return "MouseClickedCommand{componentName: $componentName, button: $button, x: $x, y: $y, clickCount: $clickCount, ${super.toString()}}";
  }
}
