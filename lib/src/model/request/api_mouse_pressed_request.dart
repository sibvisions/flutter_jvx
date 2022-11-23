import 'api_mouse_request.dart';

class ApiMousePressedRequest extends ApiMouseRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiMousePressedRequest({
    required super.componentName,
    super.button,
    super.clickCount,
    super.x,
    super.y,
  });
}
