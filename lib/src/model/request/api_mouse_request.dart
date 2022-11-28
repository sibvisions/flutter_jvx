import '../../service/api/shared/api_object_property.dart';
import 'session_request.dart';

enum MouseButtonClicked { Left, Middle, Right }

abstract class ApiMouseRequest extends SessionRequest {
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

  ApiMouseRequest({
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
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.componentId: componentName,
        ...(button != null ? {ApiObjectProperty.button: button} : {}),
        ...(x != null ? {ApiObjectProperty.x: x} : {}),
        ...(y != null ? {ApiObjectProperty.y: y} : {}),
        ...(clickCount != null ? {ApiObjectProperty.clickCount: clickCount} : {}),
      };
}
